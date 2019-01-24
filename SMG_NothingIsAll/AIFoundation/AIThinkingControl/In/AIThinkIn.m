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
#import "AIAlgNodeBase.h"
#import "NSString+Extension.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "AINet.h"
#import "AINetAbsFoNode.h"
#import "AIAbsCMVNode.h"

@implementation AIThinkIn

-(void) dataIn:(NSObject*)algsModel{
    //1. 装箱(除mv有两个元素外一般仅有一个元素)
    NSArray *algsArr = [ThinkingUtils algModelConvert2Pointers:algsModel];
    
    //2. 检测imv
    BOOL findMV = [ThinkingUtils dataIn_CheckMV:algsArr];
    
    //3. 分流_mv时
    if (findMV) {
        ///输入新的cmvAlgsArr(下面已有assExp中,有mv方向的添加mvCache代码,此处去掉)
        //[self.demandManager dataIn_CmvAlgsArr:algsArr];
        
        ///1. 联想到mv时,创建NetCmvModel;
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CreateCMVModel:)]) {
            AIFrontOrderNode *foNode = [self.delegate aiThinkIn_CreateCMVModel:algsArr];
            
            ///2. 联想经验
            [self dataIn_AssociativeExperience:foNode];
        }
    }else{
        ///1. 打包成algTypeNode;
        AIPointer *algNode_p = [ThinkingUtils createAlgNodeWithValue_ps:algsArr];
        
        ///2. 加入瞬时记忆
        if (algNode_p && self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
            [self.delegate aiThinkIn_AddToShortMemory:@[algNode_p]];
        }
        
        ///3. 联想信息
        [self dataIn_AssociativeData:algNode_p];
    }
}

/**
 *  MARK:--------------------dataIn潜意识assExp--------------------
 *  1. 无条件
 *  2. 有尝(energy-1)
 *  3. 指定model
 *  注: dataIn负责护送一次指定信息的ass(随后进入dataOut递归循环)
 *  注: dataIn_assExp可直接跳过检查点一次;
 */
-(void) dataIn_AssociativeExperience:(AIFrontOrderNode*)foNode {
    if (ISOK(foNode, AIFrontOrderNode.class)) {
        //1. 取cmvNode
        AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        if (ISOK(cmvNode, AICMVNode.class)) {
            //2. 根据cmv模型,取cmv的迫切度值和欲望方向;求出需求
            NSNumber *deltaNum = [SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime];
            NSInteger delta = [NUMTOOK(deltaNum) integerValue];
            
            //3. 思考mv
            //BOOL havDemand = [ThinkingUtils getDemand:cmvNode.urgentTo_p.algsType delta:delta complete:nil];
            //TODO:>>>>判断需求;(如饿,主动取当前状态,是否饿)
            if (delta != 0) {
                [self dataIn_AssExp_ToOutLoop:cmvNode];
            }
            
            //4. 思考数据
            [self dataIn_AssExp_ToLawAbsData:foNode cmvNode:cmvNode];
        }
    }
    //5. 消耗energy
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
        [self.delegate aiThinkIn_UpdateEnergy:-1];
    }
}

//MARK:===============================================================
//MARK:                     < dataIn_Ass >
//MARK:===============================================================

/**
 *  MARK:--------------------联想相关数据(看到西瓜会开心)(识别)--------------------
 *  1. 注:直至desicionOut前,assCmv都会真实作用于thinkingControl
 *  2. assCmv首先会通过energy和cmvCache表现在thinkingControl中,影响思维循环;
 *  3. dataIn负责护送一次指定信息的ass(随后进入递归循环)
 *  注: 局部匹配_后面通过调整参数,来达到99%以上的识别率;
 */
-(void) dataIn_AssociativeData:(AIPointer*)algNode_p {
    //1. 数据准备
    AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:algNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    AIAlgNodeBase *assAlgNode = nil;
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        ///1. 绝对匹配 -> (header匹配)
        NSString *valuesMD5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:[SMGUtils sortPointers:algNode.value_ps]]]);
        for (AIPointer *value_p in algNode.value_ps) {
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
            for (AIPointer *value_p in algNode.value_ps) {
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
    
    //3. strong++ & assFo & mvCache (识别到的信息,是否可以激活mv与思维)
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        ///1. strong++
        [AINetUtils insertPointer:assAlgNode.pointer toRefPortsByValues:assAlgNode.value_ps ps:assAlgNode.value_ps];
        
        ///2. assAlgNode的引用序列联想assFo
        AIPort *firstPort = ARR_INDEX(assAlgNode.refPorts, 0);
        if (!firstPort) {
            return;
        }
        AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:firstPort.target_p fileName:FILENAME_Node];
        if (ISOK(foNode, AIFoNodeBase.class)) {
            ///3. 联想到cmv模型前因
            AICMVNode *cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
            
            ///4. 将联想到的cmv更新energy和cmvCache
            NSString *algsType = cmvNode.urgentTo_p.algsType;
            NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
            NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
            if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
                [self.delegate aiThinkIn_UpdateEnergy:((urgentTo + 9)/10)];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateCMVCache:urgentTo:delta:order:)]) {
                [self.delegate aiThinkIn_UpdateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
            }
            
            ///5. 形成循环,根据当前最前排mv和energy,再进行思维;
            if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_ToThinkOut)]) {
                [self.delegate aiThinkIn_ToThinkOut];
            }
            
            ///6. log
            NSLog(@"联想到cmvNode: %@",[NVUtils getCmvModelDesc_ByCmvNode:cmvNode]);
        }
        //联想到数据网络节点
        //TODO:将结果存到shortCache(目前以看到的为主,想到的没存)或thinkFeedCache(人脑有短中长时缓存)//需要时,再说;
    }
}

/**
 *  MARK:--------------------对输入的mv更新mvCache并进入outLoop--------------------
 *  1. 有需求时,找出imv解决经验,尝试决策并解决;
 *  2. 已扩展对out_p的支持
 *  3. 此处交给mvCache序列,并由loop决定是否优先执行此mv;
 */
-(void) dataIn_AssExp_ToOutLoop:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (cmvNode == nil) {
        return;
    }
    
    //2. 将联想到的cmv更新energy和cmvCache
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
        [self.delegate aiThinkIn_UpdateEnergy:((urgentTo + 9)/10)];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateCMVCache:urgentTo:delta:order:)]) {
        [self.delegate aiThinkIn_UpdateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    }
    
    //3. 形成循环,根据当前最前排mv和energy,再进行思维;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_ToThinkOut)]) {
        [self.delegate aiThinkIn_ToThinkOut];
    }
}


/**
 *  MARK:--------------------输出数据的规律和抽象方向思考--------------------
 *  1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *  2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 */
-(void) dataIn_AssExp_ToLawAbsData:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode {
    //1. 数据检查
    if (foNode == nil || cmvNode == nil) {
        return;
    }
    
    //2. 联想相关数据
    NSMutableArray *assDirectionPorts = [NSMutableArray new];
    NSArray *assDirectionPorts_Nag = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:MVDirection_Negative limit:2];
    NSArray *assDirectionPorts_Pos = [[AINet sharedInstance] getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:MVDirection_Positive limit:2];
    [assDirectionPorts addObjectsFromArray:ARRTOOK(assDirectionPorts_Nag)];
    [assDirectionPorts addObjectsFromArray:ARRTOOK(assDirectionPorts_Pos)];
    
    //3. 联想cmv模型
    for (AIPort *assDirectionPort in assDirectionPorts) {
        id assDirectionNode = [SMGUtils searchObjectForPointer:assDirectionPort.target_p fileName:FILENAME_Node];
        
        if (ISOK(assDirectionNode, AICMVNodeBase.class)) {
            AICMVNodeBase *ass_cn = (AICMVNodeBase*)assDirectionNode;
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:ass_cn.pointer]) {
                AIFoNodeBase *assFrontNode = [SMGUtils searchObjectForPointer:ass_cn.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
                
                if (ISOK(assFrontNode, AINodeBase.class)) {
                    NSLog(@"\n抽象前========== %@",[NVUtils getCmvModelDesc_ByFoNode:assFrontNode]);
                    
                    //6. 类比orders的规律,并abs;
                    NSArray *orderSames = [ThinkingUtils analogyOrdersA:foNode.orders_kvp ordersB:assFrontNode.orders_kvp canAss:^BOOL{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_EnergyValid)] && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
                            if ([self.delegate aiThinkIn_EnergyValid]) {
                                [self.delegate aiThinkIn_UpdateEnergy:-1];
                                return true;
                            }
                        }
                        return false;
                    } buildAlgNode:^AIAbsAlgNode *(NSArray *algSames, AIAlgNode *algA, AIAlgNode *algB) {
                        return [theNet createAbsAlgNode:algSames algA:algA algB:algB];
                    }];
                    
                    NSString *foOrderStr = [NVUtils convertOrderPs2Str:foNode.orders_kvp];
                    NSString *assMicroStr = [NVUtils convertOrderPs2Str:assFrontNode.orders_kvp];
                    NSString *samesStr = [NVUtils convertOrderPs2Str:orderSames];
                    NSLog(@"\n抽象中========== 类比sames:\n%@\n&\n%@\n=\n%@",foOrderStr,assMicroStr,samesStr);
                    
                    //7. 已存在抽象节点或sames无效时跳过;
                    if (ARRISOK(orderSames)) {
                        BOOL samesEqualAssFo = orderSames.count == assFrontNode.orders_kvp.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFrontNode.orders_kvp];
                        BOOL jumpForAbsAlreadyHav = (ISOK(assFrontNode, AINetAbsFoNode.class) && samesEqualAssFo);
                        if (jumpForAbsAlreadyHav) {
                            ///1. 直接关联即可
                            AINetAbsFoNode *assAbsFo = (AINetAbsFoNode*)assFrontNode;
                            [AINetUtils insertPointer:foNode.pointer toPorts:assAbsFo.conPorts ps:foNode.orders_kvp];
                            [AINetUtils insertPointer:assAbsFo.pointer toPorts:foNode.absPorts ps:assAbsFo.orders_kvp];
                        }else{
                            //8. 构建absNode
                            AINetAbsFoNode *create_an = [[AINet sharedInstance] createAbs:foNode foB:foNode orderSames:orderSames];
                            
                            //9. 并把抽象节点的信息_添加到瞬时记忆
                            if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
                                [self.delegate aiThinkIn_AddToShortMemory:create_an.orders_kvp];
                            }
                            
                            //10. createAbsCmvNode
                            AIAbsCMVNode *create_acn = [theNet createAbsCMVNode:create_an.pointer aMv_p:foNode.cmvNode_p bMv_p:ass_cn.pointer];
                            
                            //11. cmv模型连接;
                            if (ISOK(create_acn, AIAbsCMVNode.class)) {
                                create_an.cmvNode_p = create_acn.pointer;
                                [SMGUtils insertObject:create_an rootPath:create_an.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
                            }
                            
                            NSLog(@"\n抽象后==========\n%@",[NVUtils getFoNodeDesc:create_an]);
                            NSLog(@"\nconPorts\n%@",[NVUtils getFoNodeConPortsDesc:create_an]);
                            NSLog(@"\nabsPorts\n%@",[NVUtils getFoNodeAbsPortsDesc:create_an]);
                            //TODO:>>>>>将absNode和absCmvNode存到thinkFeedCache;
                        }
                    }
                }
            }
        }
    }
}

@end
