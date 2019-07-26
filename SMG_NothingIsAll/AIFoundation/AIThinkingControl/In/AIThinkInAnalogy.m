//
//  AIThinkInAnalogy.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/3/20.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInAnalogy.h"
#import "AIKVPointer.h"
#import "AINetAbsFoNode.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"
#import "AIPort.h"
#import "AINet.h"
#import "AINetUtils.h"
#import "AIFrontOrderNode.h"
#import "AIAbsCMVNode.h"
#import "AINetIndex.h"

@implementation AIThinkInAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (fo && assFo) {
        for (AIKVPointer *algNodeA_p in fo.orders_kvp) {
            for (AIKVPointer *algNodeB_p in assFo.orders_kvp) {
                //2. A与B直接一致则直接添加 & 不一致则如下代码;
                if ([algNodeA_p isEqual:algNodeB_p]) {
                    [orderSames addObject:algNodeA_p];
                    break;
                }else{
                    ///1. 构建时,消耗能量值;
                    if (canAssBlock && !canAssBlock()) {
                        break;
                    }
                    
                    ///2. 取出algNodeA & algNodeB
                    AIAlgNode *algNodeA = [SMGUtils searchNode:algNodeA_p];
                    AIAlgNode *algNodeB = [SMGUtils searchNode:algNodeB_p];
                    
                    ///3. values->absPorts的认知过程
                    if (algNodeA && algNodeB) {
                        NSMutableArray *sameValue_ps = [[NSMutableArray alloc] init];
                        for (AIKVPointer *valueA_p in algNodeA.content_ps) {
                            for (AIKVPointer *valueB_p in algNodeB.content_ps) {
                                if ([valueA_p isEqual:valueB_p] && ![sameValue_ps containsObject:valueB_p]) {
                                    [sameValue_ps addObject:valueB_p];
                                    break;
                                }
                            }
                        }
                        if (ARRISOK(sameValue_ps)) {
                            [theNet createAbsAlgNode:sameValue_ps conAlgs:@[algNodeA,algNodeB] isMem:false];
                            ///4. 构建时,消耗能量值;
                            if (updateEnergy) {
                                updateEnergy();
                            }
                        }
                    }
                    
                    ///5. absPorts->orderSames (根据强度优先)
                    NSMutableArray *aAbsPorts = [[NSMutableArray alloc] init];
                    [aAbsPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:algNodeA.pointer fileName:kFNMemAbsPorts time:cRTMemPort]];
                    [aAbsPorts addObjectsFromArray:algNodeA.absPorts];
                    
                    NSMutableArray *bAbsPorts = [[NSMutableArray alloc] init];
                    [bAbsPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:algNodeB.pointer fileName:kFNMemAbsPorts time:cRTMemPort]];
                    [bAbsPorts addObjectsFromArray:algNodeB.absPorts];
                    
                    for (AIPort *aPort in aAbsPorts) {
                        for (AIPort *bPort in bAbsPorts) {
                            if ([aPort.target_p isEqual:bPort.target_p]) {
                                [orderSames addObject:bPort.target_p];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    //3. 外类比构建
    [self analogyOutside_Creater:orderSames fo:fo assFo:assFo];
}

/**
 *  MARK:--------------------外类比的构建器--------------------
 *  1. 构建absFo
 *  2. 构建absCmv
 */
+(void)analogyOutside_Creater:(NSArray*)orderSames fo:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo{
    //2. 数据检查;
    if (ARRISOK(orderSames) && ISOK(fo, AIFoNodeBase.class) && ISOK(assFo, AIFoNodeBase.class)) {
        
        //3. fo和assFo本来就是抽象关系时_直接关联即可;
        BOOL samesEqualAssFo = orderSames.count == assFo.orders_kvp.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.orders_kvp];
        BOOL jumpForAbsAlreadyHav = (ISOK(assFo, AINetAbsFoNode.class) && samesEqualAssFo);
        if (jumpForAbsAlreadyHav) {
            AINetAbsFoNode *assAbsFo = (AINetAbsFoNode*)assFo;
            [AINetUtils relateFoAbs:assAbsFo conNodes:@[fo]];
        }else{
            //4. 构建absFoNode
            AINetAbsFoNode *createAbsFo = [theNet createAbsFo_Outside:fo foB:assFo orderSames:orderSames];

            //5. createAbsCmvNode
            AICMVNodeBase *assMv = [SMGUtils searchNode:assFo.cmvNode_p];
            if (assMv) {
                AIAbsCMVNode *createAbsCmv = [theNet createAbsCMVNode_Outside:createAbsFo.pointer aMv_p:fo.cmvNode_p bMv_p:assMv.pointer];
                
                //6. cmv模型连接;
                if (ISOK(createAbsCmv, AIAbsCMVNode.class)) {
                    createAbsFo.cmvNode_p = createAbsCmv.pointer;
                    [SMGUtils insertObject:createAbsFo pointer:createAbsFo.pointer fileName:kFNNode time:cRTNode];
                }
                
                [theNV setNodeData:createAbsFo.pointer];
                [theNV setNodeData:assMv.pointer];
                [theNV setNodeData:createAbsCmv.pointer];
            }
            //TODO:>>>>>将absNode和absCmvNode存到thinkFeedCache;
        }
    }
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================
+(void) analogyInner:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
    //1. 数据检查
    if (!ISOK(checkFo, AIFoNodeBase.class)) {
        return;
    }
    NSArray *orders = ARRTOOK(checkFo.orders_kvp);
    
    //2. 每个元素,分别与orders后面所有元素进行类比
    for (NSInteger i = 0; i < orders.count; i++) {
        for (NSInteger j = i + 1; j < orders.count; j++) {
            
            //3. 检查能量值
            if (canAssBlock && !canAssBlock()) {
                return;
            }
            
            //4. 取出两个祖母
            AIKVPointer *algA_p = ARR_INDEX(orders, i);
            AIKVPointer *algB_p = ARR_INDEX(orders, j);
            AIAlgNode *algNodeA = [SMGUtils searchNode:algA_p];
            AIAlgNode *algNodeB = [SMGUtils searchNode:algB_p];
            
            //5. 内类比找不同 (比大小:同区不同值 / 有无)
            AINetAbsFoNode *abFo = nil;
            if (algNodeA && algNodeB){
                ///1. 取a差集和b差集;
                NSArray *aSub_ps = [SMGUtils removeSub_ps:algNodeB.content_ps parent_ps:[[NSMutableArray alloc] initWithArray:algNodeA.content_ps]];
                NSArray *bSub_ps = [SMGUtils removeSub_ps:algNodeA.content_ps parent_ps:[[NSMutableArray alloc] initWithArray:algNodeB.content_ps]];
                NSArray *rangeOrders = ARR_SUB(orders, i + 1, j - i - 1);
                
                ///2. 四种情况; (有且仅有1条微信息不同,进行内类比构建)
                if (aSub_ps.count == 1 && bSub_ps.count == 1) {
                    //1) 当长度都为1时,比大小:同区不同值; (对比相同算法标识的两个指针 (如,颜色,距离等))
                    AIKVPointer *a_p = ARR_INDEX(aSub_ps, 0);
                    AIKVPointer *b_p = ARR_INDEX(bSub_ps, 0);
                    if ([a_p.identifier isEqualToString:b_p.identifier]) {
                        //注: 对比微信息是否不同 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
                        if (a_p.pointerId != b_p.pointerId) {
                            NSNumber *numA = [AINetIndex getData:a_p];
                            NSNumber *numB = [AINetIndex getData:b_p];
                            NSComparisonResult compareResult = [NUMTOOK(numA) compare:NUMTOOK(numB)];
                            if (compareResult == NSOrderedAscending) {
                                abFo = [self analogyInner_Creater:AnalogyInnerType_Less target_p:a_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                            }else if (compareResult == NSOrderedDescending) {
                                abFo = [self analogyInner_Creater:AnalogyInnerType_Greater target_p:a_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                            }
                        }
                    }
                }else if(aSub_ps.count == 1 && bSub_ps.count == 0){
                    //2) 当长度各A=1和B=0时,判定A0是否为祖母: 无;
                    AIKVPointer *a_p = ARR_INDEX(aSub_ps, 0);
                    if ([kPN_ALG_ABS_NODE isEqualToString:a_p.folderName]) {
                        abFo = [self analogyInner_Creater:AnalogyInnerType_None target_p:a_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                    }
                }else if(aSub_ps.count == 0 && bSub_ps.count == 1){
                    //3) 当长度各A=0和B=1时,判定B0是否为祖母: 有;
                    AIKVPointer *b_p = ARR_INDEX(bSub_ps, 0);
                    if ([kPN_ALG_ABS_NODE isEqualToString:b_p.folderName]) {
                        abFo = [self analogyInner_Creater:AnalogyInnerType_Hav target_p:b_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                    }
                }
            }
            
            //6. 对energy消耗;
            if (!ISOK(abFo, AINetAbsFoNode.class)) {
                return;
            }
            if (updateEnergy) {
                updateEnergy();
            }
            
            //7. 内中有外
            [theNV setNodeData:abFo.pointer];
            [self analogyInner_Outside:abFo canAss:canAssBlock updateEnergy:updateEnergy];
        }
    }
}


/**
 *  MARK:--------------------内类比的构建方法--------------------
 *  @param type : 内类比类型,大小有无; (必须为四值之一,否则构建未知节点)
 *  @param target_p : 目前正在操作的指针; (可能是微信息指针,也可能是被嵌套的祖母指针)
 *  @param rangeOrders : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 *
 *  > 作用
 *  1. 构建动态微信息;
 *  2. 构建动态祖母;
 *  3. 构建abFoNode时序;
 *  4. 构建mv节点;
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyInnerType)type target_p:(AIKVPointer*)target_p algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB rangeOrders:(NSArray*)rangeOrders conFo:(AIFoNodeBase*)conFo{
    
    NSLog(@"========TODOTOMORROW:构建有无大小节点");
    
    //1. 数据检查
    rangeOrders = ARRTOOK(rangeOrders);
    if (target_p && algA && algB) {
        
        //2. 根据type来构建微信息,和祖母; (将a和b改成前和后)
        NSInteger frontData = 0,backData = 0;
        if (type == AnalogyInnerType_Greater) {
            frontData = cLess;
            backData = cGreater;
        }else if (type == AnalogyInnerType_Less) {
            frontData = cGreater;
            backData = cLess;
        }else if (type == AnalogyInnerType_Hav) {
            frontData = cNone;
            backData = cHav;
        }else if (type == AnalogyInnerType_None) {
            frontData = cHav;
            backData = cNone;
        }else{
            return nil;
        }
        
        //3. 构建动态微信息
        AIPointer *front_p = [theNet getNetDataPointerWithData:@(frontData) algsType:target_p.algsType dataSource:target_p.dataSource];
        AIPointer *back_p = [theNet getNetDataPointerWithData:@(backData) algsType:target_p.algsType dataSource:target_p.dataSource];
        if (!front_p || !back_p) {
            return nil;
        }
        
        //4. 取出绝对匹配的dynamic抽象祖母
        AIAlgNodeBase *frontAlg = [theNet getAbsoluteMatchingAlgNodeWithValueP:front_p];
        AIAlgNodeBase *backAlg = [theNet getAbsoluteMatchingAlgNodeWithValueP:back_p];
        
        //5. 构建动态抽象祖母;
        AIAlgNodeBase* (^RelateDynamicAlgBlock)(AIAlgNodeBase*, AIAlgNode*,AIPointer*) = ^AIAlgNodeBase* (AIAlgNodeBase *dynamicAbsNode, AIAlgNode *conNode,AIPointer *value_p){
            if (ISOK(dynamicAbsNode, AIAbsAlgNode.class)) {
                ///1. 有效时,关联;
                [AINetUtils relateAlgAbs:(AIAbsAlgNode*)dynamicAbsNode conNodes:@[conNode]];
            }else{
                ///2. 无效时,构建;
                if (value_p) {
                    dynamicAbsNode = [theNet createAbsAlgNode:@[value_p] conAlgs:@[conNode] isMem:false];
                }
            }
            return dynamicAbsNode;
        };
        frontAlg = RelateDynamicAlgBlock(frontAlg,algA,front_p);//从小到大
        backAlg = RelateDynamicAlgBlock(backAlg,algB,back_p);//从大到小
        
        //6. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
        if (frontAlg && backAlg) {
            NSMutableArray *absOrders = [[NSMutableArray alloc] init];
            [absOrders addObject:frontAlg.pointer];
            [absOrders addObjectsFromArray:rangeOrders];
            [absOrders addObject:backAlg.pointer];
            AINetAbsFoNode *createrFo = [theNet createAbsFo_Inner:conFo orderSames:absOrders];
            
            if (!createrFo) {
                return nil;
            }
            
            //7. 构建mv节点,形成mv基本模型;
            AIAbsCMVNode *createrMv = [theNet createAbsCMVNode_Inner:createrFo.pointer conMv_p:conFo.cmvNode_p];
            
            //8. cmv模型连接;
            if (ISOK(createrMv, AIAbsCMVNode.class)) {
                createrFo.cmvNode_p = createrMv.pointer;
                [SMGUtils insertNode:createrFo];
            }
            return createrFo;
        }
    }
    return nil;
}


/**
 *  MARK:--------------------内类比的内中有外--------------------
 *  1. 根据abFo联想assAbFo并进行外类比 (根据微信息来索引查找assAbFo)
 *  2. 复用外类比方法;
 *  3. 一个抽象了a1-range-a2的时序,必然是抽象的,必然是硬盘网络中的;所以此处不必考虑联想内存网络中的assAbFo;
 */
+(void)analogyInner_Outside:(AINetAbsFoNode*)abFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
    //1. 数据检查
    if (ISOK(abFo, AINetAbsFoNode.class)) {
        //2. 取用来联想的aAlg;
        AIPointer *a_p = ARR_INDEX(abFo.orders_kvp, 0);
        AIAlgNodeBase *aAlg = [SMGUtils searchNode:a_p];
        if (!aAlg) {
            return;
        }
        
        //3. 根据aAlg联想到的assAbFo时序;
        AIFoNodeBase *assAbFo = nil;
        for (AIPort *refPort in aAlg.refPorts) {
            ///1. 不能与abFo重复
            if (![abFo.pointer isEqual:refPort.target_p]) {
                AIFoNodeBase *refFo = [SMGUtils searchObjectForPointer:refPort.target_p fileName:kFNNode time:cRTNode];
                if (ISOK(refFo, AIFoNodeBase.class)) {
                    AIPointer *firstAlg_p = ARR_INDEX(refFo.orders_kvp, 0);
                    ///2. 必须符合aAlg在orders前面
                    if ([a_p isEqual:firstAlg_p]) {
                        assAbFo = refFo;
                        break;
                    }
                }
            }
        }
        if (!ISOK(assAbFo, AIFoNodeBase.class)) {
            return;
        }
        
        //4. 对abFo和assAbFo进行类比;
        [theNV setNodeData:assAbFo];
        [self analogyOutside:abFo assFo:assAbFo canAss:canAssBlock updateEnergy:updateEnergy];
    }
}

@end
