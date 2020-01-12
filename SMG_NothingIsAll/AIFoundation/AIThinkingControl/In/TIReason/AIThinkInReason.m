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
#import "TIRUtils.h"

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
 *  @desc 迭代记录:
 *      20190910: 识别"概念与时序",并构建纵向关联; (190910概念识别,添加了抽象关联)
 *      20191223: 局部匹配支持全含: 对assAlg和protoAlg直接做抽象关联,而不是新构建抽象;
 */
+(AIAlgNodeBase*) dataIn_NoMV_RecognitionIs:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps{
    //1. 数据准备
    AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
    if (algNode == nil) {
        return nil;
    }
    
    //2. 对value.refPorts进行检查识别; (noMv信号已输入完毕,识别联想)
    AIAlgNodeBase *assAlgNode = nil;
    ///1. 绝对匹配 -> 内存网络;
    assAlgNode = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValuePs:algNode.content_ps exceptAlg_p:algNode.pointer isMem:true];
    
    ///2. 绝对匹配 -> 硬盘网络;
    if (!assAlgNode) {
        assAlgNode = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValuePs:algNode.content_ps exceptAlg_p:algNode.pointer isMem:false];
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
    
    //3. 直接将assAlgNode设置为algNode的抽象; (这样后面TOR理性决策时,才可以直接对当前瞬时实物进行很好的理性评价);
    if (ISOK(assAlgNode, AIAlgNodeBase.class)) {
        //4. 识别到时,value.refPorts -> 更新/加强微信息的引用序列
        [AINetUtils insertRefPorts_AllAlgNode:assAlgNode.pointer value_ps:assAlgNode.content_ps ps:assAlgNode.content_ps difStrong:1];
        
        //5. 识别到时,进行抽具象 -> 关联 & 存储 (20200103:测得,algNode为内存节点时,关联也在内存)
        [AINetUtils relateAlgAbs:(AIAbsAlgNode*)assAlgNode conNodes:@[algNode]];
    }
    
    //4. 调试日志;
    if (assAlgNode && ![SMGUtils containsSub_ps:assAlgNode.content_ps parent_ps:algNode.content_ps]) {
        WLog(@"全含结果不正常,导致下面的抽象sames也不准确,,,可在git20191223找回原sames代码");
    }
    if ([NVHeUtil isHeight:5 fromContent_ps:algNode.content_ps]) {
        if (!assAlgNode) {
            NSLog(@"_______________________识别 failure");
        }else{
            NSLog(@"_______________________识别 success");
        }
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

//MARK:===============================================================
//MARK:                     < TIR_Fo >
//MARK:===============================================================

/**
 *  MARK:--------------------理性时序--------------------
 *  @param protoAlg_ps :
 *      1. 传入原始瞬时记忆序列 90% ,还是识别后的概念序列 10%;
 *      2. 传入行为化中的rethinkLSP重组fo;
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
+(void) TIR_Fo_FromRethink:(NSArray*)protoAlg_ps replaceMatchAlg:(AIAlgNodeBase*)replaceMatchAlg finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock{
    //1. 数据检查
    AIKVPointer *last_p = ARR_INDEX_REVERSE(protoAlg_ps, 0);
    AIAlgNodeBase *lastAlg = [SMGUtils searchNode:last_p];
    if (!ARRISOK(protoAlg_ps) || !lastAlg || !replaceMatchAlg) {
        return;
    }
    
    //2. 调用通用时序识别方法
    [self TIR_Fo_General:protoAlg_ps assFoIndexAlg:lastAlg assFoBlock:^NSArray *(AIAlgNodeBase *indexAlg) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if (indexAlg) {
            for (AIPort *refPort in indexAlg.refPorts) {
                //必须包含replaceMatchAlg的时序才有效;
                if ([SMGUtils containsSub_p:refPort.target_p parentPorts:replaceMatchAlg.refPorts]) {
                    [result addObject:refPort];
                    if (result.count >= cPartMatchingCheckRefPortsLimit) {
                        break;
                    }
                }
            }
        }
        return result;
    } checkItemValid:^BOOL(AIKVPointer *protoAlg, AIKVPointer *assAlg) {
        //TODOTOMORROW:
        //2. 对于此封装方法,每个item的判断,不是isEquals,所以要block回调出来,来分别对比;
        ////5> 先判断,checkFo是否包含item的"识别is"概念 (如苹果);
        //if (itemAlg) {
        //    AIAlgNodeBase *itemRecogniNode = [SMGUtils searchNode:ARR_INDEX(itemAlg.content_ps, 0)];
        //    if (itemRecogniNode) {
        //        NSInteger itemAIndex = [assFo.content_ps indexOfObject:itemRecogniNode.pointer];
        //
        //        //6> 再判断,checkFo是否包含"识别is"的再抽象概念 (如水果);
        //        if (itemAIndex == 0) {
        //
        //            //7> 写一个isBasedNode方法, (checkFo中概念节点的里氏替换原则) (目前仅从抽象一层取);
        //            for (AIPort *itemRecogniAbsPort in itemRecogniNode.absPorts) {
        //                itemAIndex = [assFo.content_ps indexOfObject:itemRecogniAbsPort.target_p];
        //            }
        //        }
        //    }
        //}

        return false;
    } finishBlock:finishBlock];
}

+(void) TIR_Fo_FromShortMem:(NSArray*)protoAlg_ps lastMatchAlg:(AIAlgNodeBase*)lastMatchAlg finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock{
    if (!ARRISOK(protoAlg_ps) || !lastMatchAlg) {
        return;
    }
    [self TIR_Fo_General:protoAlg_ps assFoIndexAlg:lastMatchAlg assFoBlock:^NSArray *(AIAlgNodeBase *indexAlg) {
        if (indexAlg) {
            return ARR_SUB(indexAlg.refPorts, 0, cPartMatchingCheckRefPortsLimit);
        }
        return nil;
    } checkItemValid:^BOOL(AIKVPointer *protoAlg, AIKVPointer *assAlg) {
        //TODOTOMORROW:
        //2. 对于此封装方法,每个item的判断,不是isEquals,所以要block回调出来,来分别对比;
        ////5> 先判断,checkFo是否包含item的"识别is"概念 (如苹果);
        //if (itemAlg) {
        //    AIAlgNodeBase *itemRecogniNode = [SMGUtils searchNode:ARR_INDEX(itemAlg.content_ps, 0)];
        //    if (itemRecogniNode) {
        //        NSInteger itemAIndex = [assFo.content_ps indexOfObject:itemRecogniNode.pointer];
        //
        //        //6> 再判断,checkFo是否包含"识别is"的再抽象概念 (如水果);
        //        if (itemAIndex == 0) {
        //
        //            //7> 写一个isBasedNode方法, (checkFo中概念节点的里氏替换原则) (目前仅从抽象一层取);
        //            for (AIPort *itemRecogniAbsPort in itemRecogniNode.absPorts) {
        //                itemAIndex = [assFo.content_ps indexOfObject:itemRecogniAbsPort.target_p];
        //            }
        //        }
        //    }
        //}

        return false;
    } finishBlock:finishBlock];
}

+(void) TIR_Fo_General:(NSArray*)protoAlg_ps
         assFoIndexAlg:(AIAlgNodeBase*)assFoIndexAlg
            assFoBlock:(NSArray*(^)(AIAlgNodeBase *indexAlg))assFoBlock
        checkItemValid:(BOOL(^)(AIKVPointer *protoAlg,AIKVPointer *assAlg))checkItemValid
           finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock{
    
    //1. 将alg_ps构建成时序; (把每次dic输入,都作为一个新的内存时序)
    AIFrontOrderNode *protoFo = [theNet createConFo:protoAlg_ps];
    
    //2. 局部匹配识别时序;
    __block AIFoNodeBase *weakMatchFo = nil;
    __block CGFloat weakMatchValue = 0;
    [self partMatching_Fo:protoFo assFoIndexAlg:assFoIndexAlg assFoBlock:assFoBlock checkItemValid:checkItemValid finishBlock:^(id matchFo, CGFloat matchValue) {
        weakMatchFo = matchFo;
        weakMatchValue = matchValue;
    }];
    
    //3. 返回;
    if (finishBlock) {
        finishBlock(protoFo,weakMatchFo,weakMatchValue);
    }
}


/**
 *  MARK:--------------------时序的局部匹配--------------------
 *  参考: n17p7 TIR_FO模型到代码
 *  @param assFoIndexAlg    : 用来联想fo的索引概念 (shortMem的第3层 或 rethink的第1层)
 *  @param assFoBlock       : 联想fos (联想有效的5个)
 *  @param checkItemValid   : 检查item(fo.alg)的有效性 notnull
 *  @param finishBlock      : 完成 notnull
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
 *  @迭代记录:
 *      20191231: 测试到,点击饥饿,再点击乱投,返回matchFo:nil matchValue:0;所以针对此识别失败问题,发现了_fromShortMem和_fromRethink的不同,且支持了两层assFo,与全含;(参考:n18p2)
 *
 */
+(void) partMatching_Fo:(AIFoNodeBase*)protoFo
          assFoIndexAlg:(AIAlgNodeBase*)assFoIndexAlg
             assFoBlock:(NSArray*(^)(AIAlgNodeBase *indexAlg))assFoBlock
         checkItemValid:(BOOL(^)(AIKVPointer *protoAlg,AIKVPointer *assAlg))checkItemValid
            finishBlock:(void(^)(AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock{
    //1. 数据准备
    if (!ISOK(protoFo, AIFoNodeBase.class) || !assFoIndexAlg) {
        finishBlock(nil,0);
        return;
    }
    __block BOOL successed = false;
    
    //2. 取assIndexes (取递归两层)
    NSMutableArray *assIndexes = [[NSMutableArray alloc] init];
    [assIndexes addObject:assFoIndexAlg.pointer];
    [assIndexes addObjectsFromArray:[SMGUtils convertPointersFromPorts:assFoIndexAlg.absPorts_All]];
    
    //3. 递归进行assFos
    for (AIKVPointer *assIndex_p in assIndexes) {
        AIAlgNodeBase *indexAlg = [SMGUtils searchNode:assIndex_p];
        
        //4. indexAlg.refPorts; (取识别到过的抽象节点(如苹果));
        NSArray *assFoPorts = ARRTOOK(assFoBlock(indexAlg));
        
        //5. 依次对assFos对应的时序,做匹配度评价; (参考: 160_TIRFO单线顺序模型)
        for (AIPort *assFoPort in assFoPorts) {
            AIFoNodeBase *assFo = [SMGUtils searchNode:assFoPort.target_p];
            
            //6. 对assFo做匹配判断;
            [TIRUtils TIR_Fo_CheckFoValidMatch:protoFo assFo:assFo checkItemValid:checkItemValid success:^(NSInteger lastAssIndex, CGFloat matchValue) {
                NSLog(@"匹配成功,匹配度为:%f",matchValue);
                successed = true;
                finishBlock(assFo,matchValue);
            } failure:^(NSString *msg) {
                WLog(@"%@",msg);
            }];
            
            //7. 成功一条即return
            if (successed) {
                return;
            }
        }
    }
    
    
    //TODOTOMORROW:
    //1. 此处并不能根据proto取到match;因为last_p其实是parentAlg,而不是protoAlg;
    //2. 四层FO_此处,就算改掉是matchAlg,也不能单以matchAlg.refPorts来取fo,而是需要支持四层;;
    //3. 四层ALG_此处,在匹配item_Alg时,要支持先contains,再从四层找匹配;
    //4. 全含_此处,对前半部分item_Alg,要支持全含;

}

@end
