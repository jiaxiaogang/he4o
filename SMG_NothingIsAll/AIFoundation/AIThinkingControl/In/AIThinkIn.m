//
//  AIThinkIn.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkIn.h"
#import "ThinkingUtils.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "NSString+Extension.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "AINet.h"
#import "AINetAbsFoNode.h"
#import "AIAbsCMVNode.h"
#import "AIThinkInAnalogy.h"
#import "AIAlgNode.h"
#import "AIAbsAlgNode.h"

@implementation AIThinkIn

-(void) dataInWithModels:(NSArray*)models{
    //1. 数据检查 (小鸟不能仅传入foodView,而要传入整个视角场景)
    models = ARRTOOK(models);
    
    //2. 收集所有具象父祖母的value_ps
    NSMutableArray *parentValue_ps = [[NSMutableArray alloc] init];
    NSMutableArray *subValuePsArr = [[NSMutableArray alloc] init];//2维数组
    for (NSObject *item in models) {
        NSArray *item_ps = ARRTOOK([ThinkingUtils algModelConvert2Pointers:item]);
        [parentValue_ps addObjectsFromArray:item_ps];
        [subValuePsArr addObject:item_ps];
    }
    
    //3. 构建父祖母 & 将父祖母加入瞬时记忆;
    AIAlgNode *parentAlgNode = [theNet createAlgNode:parentValue_ps isOut:false];
    if (parentAlgNode && self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
        [self.delegate aiThinkIn_AddToShortMemory:@[parentAlgNode.pointer]];
    }
    
    //4. 构建子祖母 (抽象祖母,并嵌套);
    for (NSArray *subValue_ps in subValuePsArr) {
        AIAbsAlgNode *subAlgNode = [theNet createAbsAlgNode:subValue_ps alg:parentAlgNode];
        
        //5. NoMv处理;
        [self dataIn_NoMV:subAlgNode.pointer];
    }
}

-(void) dataIn:(NSObject*)algsModel{
    //1. 装箱(除mv有两个元素外一般仅有一个元素)
    NSArray *algsArr = [ThinkingUtils algModelConvert2Pointers:algsModel];
    
    //2. 检测imv
    BOOL findMV = [ThinkingUtils dataIn_CheckMV:algsArr];
    
    //3. 分流_mv时
    if (findMV) {
        [self dataIn_FindMV:algsArr];
    }else{
        //1. 打包成algTypeNode;
        AIAlgNodeBase *algNode = [theNet createAlgNode:algsArr isOut:false];
        
        //2. 加入瞬时记忆
        if (algNode && self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
            [self.delegate aiThinkIn_AddToShortMemory:@[algNode.pointer]];
        }
        
        [self dataIn_NoMV:algNode.pointer];
    }
}

//MARK:===============================================================
//MARK:                     < NoMV >
//MARK:===============================================================

/**
 *  MARK:--------------------输入非mv信息时--------------------
 *  1. 看到西瓜会开心 : TODO: 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 */
-(void) dataIn_NoMV:(AIPointer*)algNode_p{
    if (!algNode_p) {
        return;
    }
    
    //3. 识别
    AIAlgNodeBase *recognitionAlgNode = [self dataIn_NoMV_RecognitionIs:algNode_p];
    
    //TODOWAIT:
    //4. 识别后,要进行类比,并构建网络关联; (参考n16p7)
    
    //4. 识别做什么用
    AICMVNodeBase *mvNode = [self dataIn_NoMV_RecognitionUse:recognitionAlgNode];
    
    //5. 看到西瓜会开心
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CommitMvNode:)]) {
        [self.delegate aiThinkIn_CommitMvNode:mvNode];
    }
}


/**
 *  MARK:--------------------识别是什么(这是西瓜)--------------------
 *  注: 无条件 & 目前无能量消耗 (以后有基础思维活力值后可energy-1)
 *  注: 局部匹配_后面通过调整参数,来达到99%以上的识别率;
 *  问题: 看到的algNode与识别到的,未必是正确的,但我们应该保持使用protoAlgNode而不是recognitionAlgNode;
 *  TODOV1.1:祖母的嵌套,有可能会导致识别上的一些问题; (我们需要支持结构化识别,而不仅是绝对识别和模糊识别)
 */
-(AIAlgNodeBase*) dataIn_NoMV_RecognitionIs:(AIPointer*)algNode_p {
    //1. 数据准备
    AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:algNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    AIAlgNodeBase *assAlgNode = nil;
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        ///1. 绝对匹配 -> (header匹配)
        NSString *valuesMD5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:[SMGUtils sortPointers:algNode.content_ps]]]);
        for (AIPointer *value_p in algNode.content_ps) {
            NSArray *refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime]);
            for (AIPort *refPort in refPorts) {
                
                ///2. 依次绝对匹配header,找到则break;
                if (![refPort.target_p isEqual:algNode.pointer] && [valuesMD5 isEqualToString:refPort.header]) {
                    assAlgNode = [SMGUtils searchObjectForPointer:refPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                    break;
                }
            }
            if (assAlgNode) {
                break;
            }
        }
        
        ///3. 局部匹配 -> (从values的8个value.refPorts找前3个, 3*8=24)
        if (assAlgNode == nil) {
            
            ///4. 计数器对强度前3进行计数
            NSMutableDictionary *countDic = [[NSMutableDictionary alloc] init];
            for (AIPointer *value_p in algNode.content_ps) {
                NSArray *refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime]);
                refPorts = [refPorts subarrayWithRange:NSMakeRange(0, MIN(cAssDataLimit, refPorts.count))];
                for (AIPort *refPort in refPorts) {
                    if (![refPort.target_p isEqual:algNode.pointer]) {
                        NSData *key = [NSKeyedArchiver archivedDataWithRootObject:refPort.target_p];
                        int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                        [countDic setObject:@(oldCount + 1) forKey:key];
                    }
                }
            }
            
            ///5. 找出计数最大的key
            NSData *maxKey = nil;
            for (NSData *key in countDic.allKeys) {
                if (maxKey == nil || ([NUMTOOK([countDic objectForKey:maxKey]) intValue] < [NUMTOOK([countDic objectForKey:key]) intValue])) {
                    maxKey = key;
                }
            }
            
            ///6. 取出对应的assAlgNode
            if (maxKey) {
                AIKVPointer *max_p = [NSKeyedUnarchiver unarchiveObjectWithData:maxKey];
                assAlgNode = [SMGUtils searchObjectForPointer:max_p fileName:FILENAME_Node time:cRedisNodeTime];
            }
        }
    }
    
    //3. strong++
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        [AINetUtils insertPointer:assAlgNode.pointer toRefPortsByValues:assAlgNode.content_ps ps:assAlgNode.content_ps];
        
    }
    return assAlgNode;
}


/**
 *  MARK:--------------------识别有什么用(西瓜能吃)--------------------
 *  1. assCmv首先会通过energy和cmvCache表现在thinkingControl中,影响思维循环;
 *  2. dataIn负责护送一次指定信息的ass(随后进入递归循环)
 *
 *  注: 直至desicionOut前,assCmv都会真实作用于thinkingControl
 *  注: dataIn负责护送一次指定信息的ass(随后进入dataOut递归循环)
 *  注: dataIn_assExp可直接跳过检查点一次;
 *  TODO:将结果存到shortCache(目前以看到的为主,想到的没存)或thinkFeedCache(人脑有短中长时缓存)//需要时,再说;
 */
-(AICMVNode*) dataIn_NoMV_RecognitionUse:(AIAlgNodeBase*)recognitionAlgNode{
    
    //1. assFo & mvCache (识别到的信息,是否可以激活mv与思维)
    if (!ISOK(recognitionAlgNode, AIAlgNodeBase.class)) {
        return nil;
    }
    
    //2. assAlgNode的引用序列联想assFo
    AIPort *firstPort = ARR_INDEX(recognitionAlgNode.refPorts, 0);
    if (!firstPort) {
        return nil;
    }
    
    //3. 取到最强引用节点
    AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:firstPort.target_p fileName:FILENAME_Node];
    if (!ISOK(foNode, AIFoNodeBase.class)) {
        return nil;
    }
        
    //4. 联想mvNode返回;
    AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    NSLog(@"联想到cmvNode: %@",[NVUtils getCmvModelDesc_ByCmvNode:cmvNode]);
    return cmvNode;
}


//MARK:===============================================================
//MARK:                     < FindMV >
//MARK:===============================================================

-(void) dataIn_FindMV:(NSArray*)algsArr{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    AIFrontOrderNode *foNode = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CreateCMVModel:)]) {
        foNode = [self.delegate aiThinkIn_CreateCMVModel:algsArr];
    }
    if (!ISOK(foNode, AIFrontOrderNode.class)) {
        return;
    }
    
    //2. 取cmvNode
    AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    
    //3. 思考mv,需求处理
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CommitMvNode:)]) {
        [self.delegate aiThinkIn_CommitMvNode:cmvNode];
    }
    
    //4. 学习
    [self dataIn_FindMV_Learning:foNode cmvNode:cmvNode];
}

/**
 *  MARK:--------------------学习--------------------
 *  分为:
 *   1. 外类比
 *   2. 内类比
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 */
-(void) dataIn_FindMV_Learning:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (foNode == nil || cmvNode == nil) {
        return;
    }
    
    //2. 联想相关数据
    NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;
    NSArray *directionPorts = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:direction limit:2];
    
    //3. 外类比_以mv为方向,联想assFo
    for (AIPort *assDirectionPort in ARRTOOK(directionPorts)) {
        id assDirectionNode = [SMGUtils searchObjectForPointer:assDirectionPort.target_p fileName:FILENAME_Node];
        
        if (ISOK(assDirectionNode, AICMVNodeBase.class)) {
            AICMVNodeBase *ass_cn = (AICMVNodeBase*)assDirectionNode;
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:ass_cn.pointer]) {
                AIFoNodeBase *assFrontNode = [SMGUtils searchObjectForPointer:ass_cn.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
                
                if (ISOK(assFrontNode, AINodeBase.class)) {
                    NSLog(@"\n抽象前========== %@",[NVUtils getCmvModelDesc_ByFoNode:assFrontNode]);
                    
                    //5. 执行外类比;
                    [AIThinkInAnalogy analogyOutside:foNode assFo:assFrontNode canAss:^BOOL{
                        return [self canAss];
                    } updateEnergy:^{
                        [self updateEnergy];
                    }];
                }
            }
        }
    }
    
    //12. 内类比
    [AIThinkInAnalogy analogyInner:foNode canAss:^BOOL{
        return [self canAss];
    } updateEnergy:^{
        [self updateEnergy];
    }];
}

//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

//联想前判断;
-(BOOL) canAss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_EnergyValid)]) {
        return [self.delegate aiThinkIn_EnergyValid];
    }
    return false;
}

//消耗能量值 (目前仅在构建后);
-(void) updateEnergy{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
        [self.delegate aiThinkIn_UpdateEnergy:-1];
    }
}

@end
