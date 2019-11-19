//
//  AIThinkInReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInReason.h"
#import "AINetUtils.h"
#import "NVHeUtil.h"
#import "AIKVPointer.h"
#import "NVHeader.h"
#import "NSString+Extension.h"
#import "AIPort.h"
#import "AINetIndexUtils.h"
#import "AIAlgNode.h"
#import "AICMVNode.h"
#import "AINetAbsFoNode.h"
#import "AIFrontOrderNode.h"
#import "AIAbsAlgNode.h"
#import "AINetIndex.h"

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
        assAlgNode = [AINetIndexUtils partMatching_Alg:algNode isMem:true except_ps:fromGroup_ps];
    }
    
    ///4. 局部匹配 -> 硬盘网络;
    if (!assAlgNode) {
        assAlgNode = [AINetIndexUtils partMatching_Alg:algNode isMem:false except_ps:fromGroup_ps];
    }
    
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        //3. 类比algNode和assAlgNode,并抽象;
        NSMutableArray *same_ps = [[NSMutableArray alloc] init];
        for (AIPointer *item_p in algNode.content_ps) {
            if ([SMGUtils containsSub_p:item_p parent_ps:assAlgNode.content_ps]) {
                [same_ps addObject:item_p];
            }
        }
        if (ARRISOK(same_ps)) {
            result = [theNet createAbsAlgNode:same_ps conAlgs:@[assAlgNode,algNode] isMem:false];
        }
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
+(void) TIR_Fo:(NSArray*)alg_ps finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock{
    
    //1. 将alg_ps构建成时序; (把每次dic输入,都作为一个新的内存时序)
    AIFrontOrderNode *shortMemFo = [theNet createConFo:alg_ps];
    
    //2. 局部匹配识别时序;
    __block AIFoNodeBase *weakMatchFo = nil;
    __block CGFloat weakMatchValue = 0;
    [self partMatching_Fo:shortMemFo finishBlock:^(id matchFo, CGFloat matchValue) {
        weakMatchFo = matchFo;
        weakMatchValue = matchValue;
    }];
    
    //3. 返回;
    if (finishBlock) {
        finishBlock(shortMemFo,weakMatchFo,weakMatchValue);
    }
}


/**
 *  MARK:--------------------时序的局部匹配--------------------
 *  参考: n17p7 TIR_FO模型到代码
 *  TODO_TEST_HERE:调试Pointer能否indexOfObject
 *  TODO_TEST_HERE:调试下item_p在indexOfObject中,有多个时,怎么办;
 *  TODO_TEST_HERE:测试下cPartMatchingThreshold配置值是否合理;
 *  @desc1: 在类比中,仅针对最后一个元素,与前面元素进行类比;
 *  @desc2: 内类比大小,将要取消(由外类比取代),此处不再支持;而内类比有无,此处理性概念全是"有";
 *  @desc:
 *      1. 根据最后一个节点,取refPorts,
 *      2. 对共同引用者的,顺序,看是否是正确的从左到右顺序;
 *      3. 能够匹配到更多个概念节点,越预测准确;
 *  TODO_FUTURE:判断概念匹配,目前仅支持一层抽象判断,是否要支持多层?实现方式比如(索引 / TIRAlg和TIRFo的协作);
 *
 */
+(void) partMatching_Fo:(AIFoNodeBase*)shortMemFo finishBlock:(void(^)(id matchFo,CGFloat matchValue))finishBlock{
    //1. 数据准备
    if (!finishBlock) {
        return;
    }
    if (!ISOK(shortMemFo, AIFoNodeBase.class)) {
        finishBlock(nil,0);
    }
    
    //2. 取lastAlg.refPorts; (取识别到过的抽象节点(如苹果));
    AIKVPointer *last_p = ARR_INDEX(shortMemFo.content_ps, shortMemFo.content_ps.count - 1);
    AIAlgNodeBase *lastConNode = [SMGUtils searchNode:last_p];
    if (!lastConNode) {
        finishBlock(nil,0);
    }
    AIAlgNodeBase *lastRecogniNode = [SMGUtils searchNode:ARR_INDEX(lastConNode.absPorts, 0)];
    if (!lastRecogniNode) {
        finishBlock(nil,0);
    }
    NSArray *lastRecogniRefPorts = ARR_SUB(lastRecogniNode.refPorts, 0, cPartMatchingCheckRefPortsLimit);
    
    //3. 依次对lastRefPorts对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
    CGFloat maxMatchValue = 0;
    AIFoNodeBase *maxMatchFo = nil;
    for (AIPort *checkPort in lastRecogniRefPorts) {
        AIFoNodeBase *checkFo = [SMGUtils searchNode:checkPort.target_p];
        
        //1> 匹配度
        CGFloat matchValue = 0;
        if (checkFo) {
            //2> 从后向前,逐个匹配;
            NSInteger lastAIndex = [checkFo.content_ps indexOfObject:lastRecogniNode.pointer];
            
            //3> 默认有效数为1 (因为lastAlg肯定有效);
            int validCount = 1;
            
            //4> 有效匹配计数: (proto中,在checkFo中总Alg有效数);
            for (NSInteger i = shortMemFo.content_ps.count - 2; i >= 0; i--) {
                AIKVPointer *item_p = ARR_INDEX(shortMemFo.content_ps, i);
                AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
                
                //5> 先判断,checkFo是否包含item的"识别is"概念 (如苹果);
                if (itemAlg) {
                    AIAlgNodeBase *itemRecogniNode = [SMGUtils searchNode:ARR_INDEX(itemAlg.content_ps, 0)];
                    if (itemRecogniNode) {
                        NSInteger itemAIndex = [checkFo.content_ps indexOfObject:itemRecogniNode.pointer];
                        
                        //6> 再判断,checkFo是否包含"识别is"的再抽象概念 (如水果);
                        if (itemAIndex == 0) {
                            
                            //7> 写一个isBasedNode方法, (checkFo中概念节点的里氏替换原则) (目前仅从抽象一层取);
                            for (AIPort *itemRecogniAbsPort in itemRecogniNode.absPorts) {
                                itemAIndex = [checkFo.content_ps indexOfObject:itemRecogniAbsPort.target_p];
                                
                                //8> 找到有效的,则break;
                                if (itemAIndex < lastAIndex) {
                                    break;
                                }
                            }
                        }
                        //9> 左概念,在更左边,则有效;
                        if (itemAIndex < lastAIndex) {
                            validCount++;
                            lastAIndex = itemAIndex;
                        }
                    }
                }
            }
            
            //10> 匹配度计算;
            matchValue = (float)validCount / checkFo.content_ps.count;
            
            //11> 保留匹配度最高的结果;
            if (matchValue > cPartMatchingThreshold && matchValue > maxMatchValue) {
                maxMatchValue = matchValue;
                maxMatchFo = checkFo;
            }
        }
    }
    
    //4. 返回值
    if (finishBlock) {
        finishBlock(maxMatchFo,maxMatchValue);
    }
}

@end
