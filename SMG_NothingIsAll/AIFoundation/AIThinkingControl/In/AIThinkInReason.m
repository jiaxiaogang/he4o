//
//  AIThinkInReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInReason.h"
#import "AIAlgNodeBase.h"
#import "AINetUtils.h"
#import "NVHeUtil.h"
#import "AICMVNode.h"
#import "AIAlgNodeBase.h"
#import "AIKVPointer.h"
#import "NVHeader.h"
#import "NSString+Extension.h"
#import "AIPort.h"
#import "AIAbsAlgNode.h"

@implementation AIThinkInReason

//MARK:===============================================================
//MARK:                     < TIR_Alg >
//MARK:===============================================================

/**
 *  MARK:--------------------输入非mv信息时--------------------
 *  1. 看到西瓜会开心 : TODO: 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 *  @param fromGroup_ps : 当前输入批次的整组概念指针;
 */
+(void) dataIn_NoMV:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps finishBlock:(void(^)(AIAlgNodeBase *isNode,AICMVNodeBase *useNode))finishBlock{
    if (!algNode_p) {
        return;
    }
    
    //3. 识别
    AIAlgNodeBase *recognitionAlgNode = [self dataIn_NoMV_RecognitionIs:algNode_p fromGroup_ps:fromGroup_ps];
    
    //TODOWAIT:
    //4. 识别后,要进行类比,并构建网络关联; (参考n16p7)
    
    //4. 识别做什么用
    AICMVNodeBase *mvNode = [self dataIn_NoMV_RecognitionUse:recognitionAlgNode];
    
    //5. 看到西瓜会开心
    if (finishBlock) {
        finishBlock(recognitionAlgNode,mvNode);
    }
}

/**
 *  MARK:--------------------识别是什么(这是西瓜)--------------------
 *  注: 无条件 & 目前无能量消耗 (以后有基础思维活力值后可energy-1)
 *  注: 局部匹配_后面通过调整参数,来达到99%以上的识别率;
 *
 *  Q1: 老问题,看到的algNode与识别到的,未必是正确的,但我们应该保持使用protoAlgNode而不是recognitionAlgNode;
 *  A1: 190910在理性思维完善后,识别result和protoAlg都有用;
 *
 *  Q2: 概念的嵌套,有可能会导致识别上的一些问题; (我们需要支持结构化识别,而不仅是绝对识别和模糊识别)
 *  A2: 190910概念嵌套已取消,正在做结构化识别,此次改动是为了完善ThinkReason细节;
 *
 *  TODO: 190910识别"概念与时序",并构建纵向关联;
 *  STATUST: 190910概念识别,添加了抽象关联;
 */
+(AIAlgNodeBase*) dataIn_NoMV_RecognitionIs:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps{
    //1. 数据准备
    AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
    AIAlgNodeBase *result = nil;
    if (algNode == nil) {
        return nil;
    }
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    AIAlgNodeBase *assAlgNode = nil;
    ///1. 绝对匹配 -> 内存网络;
    assAlgNode = [self recognition_AbsoluteMatching:algNode isMem:true];
    
    ///2. 绝对匹配 -> 硬盘网络;
    if (!assAlgNode) {
        assAlgNode = [self recognition_AbsoluteMatching:algNode isMem:false];
    }
    
    ///3. 局部匹配 -> 内存网络;
    ///(19xxxx注掉,不能太过于脱离持久网络做思考,所以先注掉)
    ///(190625放开,因采用内存网络后,靠这识别)
    if (!assAlgNode) {
        assAlgNode = [self recognition_PartMatching:algNode isMem:true except_ps:fromGroup_ps];
    }
    
    ///4. 局部匹配 -> 硬盘网络;
    if (!assAlgNode) {
        assAlgNode = [self recognition_PartMatching:algNode isMem:false except_ps:fromGroup_ps];
    }
    
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        //3. 对algNode_p和assAlgNode进行抽具象关联;
        if (ISOK(assAlgNode, AIAbsAlgNode.class)) {
            [AINetUtils relateAlgAbs:(AIAbsAlgNode*)assAlgNode conNodes:@[algNode]];
            result = assAlgNode;
        }else{
            result = [theNet createAbsAlgNode:assAlgNode.content_ps conAlgs:@[assAlgNode,algNode] isMem:false];
        }
        
        //3. strong++
        [AINetUtils insertRefPorts_AllAlgNode:assAlgNode.pointer value_ps:assAlgNode.content_ps ps:assAlgNode.content_ps];
    }
    if ([NVHeUtil isHeight:5 fromContent_ps:result.content_ps]) {
        if (!result) {
            NSLog(@"_______________________识别 failure");
        }else{
            NSLog(@"_______________________识别 success");
        }
    }
    return result;
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
+(AICMVNode*) dataIn_NoMV_RecognitionUse:(AIAlgNodeBase*)recognitionAlgNode{
    
    //1. assFo & mvCache (识别到的信息,是否可以激活mv与思维)
    if (!ISOK(recognitionAlgNode, AIAlgNodeBase.class)) {
        return nil;
    }
    
    //2. assAlgNode的引用序列联想assFo (目前先仅对内存做内存操作,对硬盘做硬盘操作)
    AIPort *firstPort;
    if (recognitionAlgNode.pointer.isMem) {
        
        ///1. 尝试取_对应硬盘概念的引用序列; (有可能被迁移过)
        AIAlgNodeBase *hdRecogniAlgNode = [SMGUtils searchObjectForPointer:recognitionAlgNode.pointer fileName:kFNNode time:cRTNode];
        if (hdRecogniAlgNode) {
            firstPort = ARR_INDEX(hdRecogniAlgNode.refPorts, 0);
            if ([NVHeUtil isHeight:5 fromContent_ps:recognitionAlgNode.content_ps]) {
                if (firstPort) {
                    NSLog(@"__________________Use success");
                }else{
                    NSLog(@"__________________Use failure");
                }
            }
        }
        
        ///2. 尝试取_内存概念引用序列
        if (!firstPort) {
            NSArray *memRefPorts = [SMGUtils searchObjectForPointer:recognitionAlgNode.pointer fileName:kFNMemRefPorts time:cRTMemPort];
            firstPort = ARR_INDEX(memRefPorts, 0);
            if ([NVHeUtil isHeight:5 fromContent_ps:recognitionAlgNode.content_ps]) {
                if (firstPort) {
                    NSLog(@"__________________Use success");
                }else{
                    NSLog(@"__________________Use failure");
                }
            }
        }
    }else{
        ///3. 尝试取_硬盘概念引用序列
        firstPort = ARR_INDEX(recognitionAlgNode.refPorts, 0);
        if ([NVHeUtil isHeight:5 fromContent_ps:recognitionAlgNode.content_ps]) {
            if (firstPort) {
                NSLog(@"__________________Use success");
            }else{
                NSLog(@"__________________Use failure");
            }
        }
    }
    if (!firstPort) {
        return nil;
    }
    [theNV setNodeData:firstPort.target_p];
    [theNV lightNode:firstPort.target_p str:@"~"];
    
    //3. 取到最强引用节点
    AIFoNodeBase *foNode = [SMGUtils searchNode:firstPort.target_p];
    if (!ISOK(foNode, AIFoNodeBase.class)) {
        return nil;
    }
    
    //4. 联想mvNode返回;
    AICMVNode *cmvNode = [SMGUtils searchNode:foNode.cmvNode_p];
    [theNV setNodeData:cmvNode.pointer];
    return cmvNode;
}

/**
 *  MARK:--------------------识别_绝对匹配--------------------
 *  @param isMem : 是否从内存网络找;
 *  注: 找出与algNode绝对匹配的节点; (header匹配)
 */
+(AIAlgNodeBase*) recognition_AbsoluteMatching:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem {
    //1. 数据准备
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        NSString *valuesMD5 = [NSString md5:[SMGUtils convertPointers2String:[SMGUtils sortPointers:algNode.content_ps]]];
        valuesMD5 = STRTOOK(valuesMD5);
        
        //2. 循环对content_ps中微信息的引用序列进行匹配判定;
        for (AIPointer *value_p in algNode.content_ps) {
            NSArray *refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
            for (AIPort *refPort in refPorts) {
                
                //3. 依次绝对匹配header,找到则return;
                if (![refPort.target_p isEqual:algNode.pointer] && [valuesMD5 isEqualToString:refPort.header]) {
                    AIAlgNodeBase *assAlgNode = [SMGUtils searchNode:refPort.target_p];
                    if (assAlgNode) {
                        NSLog(@">>> %@绝对匹配成功;",isMem ? @"内存" : @"硬盘");
                        return assAlgNode;
                    }
                }
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------识别_局部匹配--------------------
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 */
+(AIAlgNodeBase*) recognition_PartMatching:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem except_ps:(NSArray*)except_ps{
    if (algNode.content_ps.count == 9 && [NVHeUtil isHeight:5 fromContent_ps:algNode.content_ps]) {
        //TODO: 仅对坚果进行识别调试;(此处坚果的refPorts为空,未被时序引用);
    }
    
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        NSMutableDictionary *countDic = [[NSMutableDictionary alloc] init];
        NSData *maxKey = nil;
        
        //2. 对每个微信息,取被引用的强度前cPartMatchingCheckRefPortsLimit个;
        for (AIPointer *value_p in algNode.content_ps) {
            NSArray *refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
            refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit);
            
            //3. 进行计数
            for (AIPort *refPort in refPorts) {
                if (![refPort.target_p isEqual:algNode.pointer] && ![SMGUtils containsSub_p:refPort.target_p parent_ps:except_ps]) {
                    NSData *key = [NSKeyedArchiver archivedDataWithRootObject:refPort.target_p];
                    int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                    [countDic setObject:@(oldCount + 1) forKey:key];
                }
            }
        }
        
        //4. 从计数器countDic 中 找出最相似(计数最大)的maxKey
        for (NSData *key in countDic.allKeys) {
            
            //5. 达到局部匹配的阀值才有效;
            int curNodeMatchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            if (((float)curNodeMatchingCount / (float)algNode.content_ps.count) >= cPartMatchingThreshold) {
                
                //6. 取最匹配的一个;
                if (maxKey == nil || ([NUMTOOK([countDic objectForKey:maxKey]) intValue] < curNodeMatchingCount)) {
                    maxKey = key;
                }
            }
        }
        
        //7. 有结果时取出对应的assAlgNode返回;
        if (maxKey) {
            AIKVPointer *max_p = [NSKeyedUnarchiver unarchiveObjectWithData:maxKey];
            AIAlgNodeBase *assAlgNode = [SMGUtils searchNode:max_p];
            NSLog(@">>> %@局部匹配成功;",isMem ? @"内存" : @"硬盘");
            return assAlgNode;
        }
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < TIR_Fo >
//MARK:===============================================================

/**
 *  MARK:--------------------理性时序--------------------
 *  @param alg_ps : 传入原始瞬时记忆序列 90% ,还是识别后的概念序列 10%;
 *  @desc 向性:
 *      1. ↑
 *      2. →
 *
 *  @desc 代码步骤:
 *      1. 用内类比的方式,发现概念的变化与有无; (理性结果)
 *      2. 用外类比的方式,匹配出靠前limit个中最相似抽象时序,并取到预测mv结果; (感性结果)
 *      3. 根据时序相似性 与 微信息差异度 得出 修正mv的紧迫度; (综合预测)
 *      4. 将fixMv添加到任务序列demandManager,做TOR处理;
 *
 *  @desc 举例步骤:
 *      1. 通过,内类比发现有一物体:方向不变 & 越来越近;
 *      2. 通过,识别概念,发现此物体是汽车; (注:已识别过,可以直接查看抽象指向);
 *      3. 通过,外类比,发现以此下去,"汽车距离变0"会撞到疼痛;
 *      4. 通过,"车-0-撞-疼"来计算时序相似度x% 与 通过"车距"y 计算= zMv;
 *      5. 将zMv提交给demandManager,做TOR处理;
 *
 */
+(void) TIR_Fo:(NSArray*)alg_ps {
    
}

@end
