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

@implementation AIThinkInAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================
+(NSArray*) analogyOutsideOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (ARRISOK(ordersA) && ARRISOK(ordersB)) {
        for (AIKVPointer *algNodeA_p in ordersA) {
            for (AIKVPointer *algNodeB_p in ordersB) {
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
                    AIAlgNode *algNodeA = [SMGUtils searchObjectForPointer:algNodeA_p fileName:FILENAME_Node time:cRedisNodeTime];
                    AIAlgNode *algNodeB = [SMGUtils searchObjectForPointer:algNodeB_p fileName:FILENAME_Node time:cRedisNodeTime];
                    
                    ///3. values->absPorts的认知过程
                    if (algNodeA && algNodeB) {
                        NSMutableArray *algSames = [[NSMutableArray alloc] init];
                        for (AIKVPointer *valueA_p in algNodeA.value_ps) {
                            for (AIKVPointer *valueB_p in algNodeB.value_ps) {
                                if ([valueA_p isEqual:valueB_p] && ![algSames containsObject:valueB_p]) {
                                    [algSames addObject:valueB_p];
                                    break;
                                }
                            }
                        }
                        if (ARRISOK(algSames)) {
                            [theNet createAbsAlgNode:algSames algA:algNodeA algB:algNodeB];
                            
                            ///4. 构建时,消耗能量值;
                            if (updateEnergy) {
                                updateEnergy();
                            }
                        }
                    }
                    
                    ///4. absPorts->orderSames (根据强度优先)
                    for (AIPort *aPort in algNodeA.absPorts) {
                        for (AIPort *bPort in algNodeB.absPorts) {
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
    return orderSames;
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================
+(void) analogyInnerOrders:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
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
            AIAlgNode *algNodeA = [SMGUtils searchObjectForPointer:algA_p fileName:FILENAME_Node time:cRedisNodeTime];
            AIAlgNode *algNodeB = [SMGUtils searchObjectForPointer:algB_p fileName:FILENAME_Node time:cRedisNodeTime];
            
            //5. 内类比找不同 (同区不同值)
            NSMutableArray *findDiffs = [[NSMutableArray alloc] init];
            if (algNodeA && algNodeB && algNodeA.value_ps.count == algNodeB.value_ps.count) {
                for (AIKVPointer *valueA_p in algNodeA.value_ps) {
                    for (AIKVPointer *valueB_p in algNodeB.value_ps) {
                        
                        ///1. 对比相同算法标识的两个指针 (如,颜色,距离等)
                        if ([valueA_p.identifier isEqualToString:valueB_p.identifier]) {
                            
                            ///2. 对比微信息是否不同 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
                            if (valueA_p.pointerId != valueB_p.pointerId) {
                                NSDictionary *diffItem = @{@"ap":valueA_p,@"bp":valueB_p,@"an":algNodeA,@"bn":algNodeB};
                                [findDiffs addObject:diffItem];
                            }
                        }
                    }
                }
            }
            
            //6. 内类比构建 (有且仅有1条微信息不同);
            if (findDiffs.count != 1) {
                continue;
            }
            NSInteger start = i + 1;
            NSInteger length = j - start;
            NSDictionary *diffItem = ARR_INDEX(findDiffs, 0);
            AINetAbsFoNode *abFo = [self analogyInnerOrders_Creater:[diffItem objectForKey:@"ap"]
                                                           valueB_p:[diffItem objectForKey:@"bp"]
                                                               algA:[diffItem objectForKey:@"an"]
                                                               algB:[diffItem objectForKey:@"bp"]
                                                        rangeOrders:ARR_SUB(orders, start, length)
                                                              conFo:checkFo];
            if (ISOK(abFo, AINetAbsFoNode.class)) {
                return;
            }
            
            //7. 对energy消耗;
            if (updateEnergy) {
                updateEnergy();
            }
            
            //8. 内中有外
            [self analogyInner_Outside:abFo canAss:canAssBlock updateEnergy:updateEnergy];
            
            
            
            
            //TODOTOMORROW:
            //3. 对于abFoNode->cmv基本模型的思考;(即abFo指向的mvNode如何生成)
        }
    }
}


/**
 *  MARK:--------------------内类比的构建方法--------------------
 *  @param rangeOrders : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 *
 *  > 作用
 *  1. 构建动态微信息;
 *  2. 构建动态祖母;
 *  3. 构建abFoNode时序;
 */
+(AINetAbsFoNode*)analogyInnerOrders_Creater:(AIKVPointer*)valueA_p valueB_p:(AIKVPointer*)valueB_p algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB rangeOrders:(NSArray*)rangeOrders conFo:(AIFoNodeBase*)conFo{
    //1. 数据检查
    rangeOrders = ARRTOOK(rangeOrders);
    if (valueA_p && valueB_p && algA && algB) {
        
        //2. 类比
        NSNumber *numA = [SMGUtils searchObjectForPointer:valueA_p fileName:FILENAME_Value time:cRedisValueTime];
        NSNumber *numB = [SMGUtils searchObjectForPointer:valueB_p fileName:FILENAME_Value time:cRedisValueTime];
        NSComparisonResult compareResult = [NUMTOOK(numA) compare:numB];
        if (compareResult == NSOrderedSame) {
            return nil;
        }
        
        //3. 构建动态微信息
        AIPointer *less_p = [theNet getNetDataPointerWithData:@(cLess) algsType:valueA_p.algsType dataSource:valueA_p.dataSource];
        AIPointer *greater_p = [theNet getNetDataPointerWithData:@(cGreater) algsType:valueA_p.algsType dataSource:valueA_p.dataSource];
        if (!less_p || !greater_p) {
            return nil;
        }
        
        //4. 取出绝对匹配的dynamic抽象祖母
        AIAlgNodeBase *lessAlg = [theNet getAbsoluteMatchingAlgNodeWithValuePs:@[less_p]];
        AIAlgNodeBase *greaterAlg = [theNet getAbsoluteMatchingAlgNodeWithValuePs:@[greater_p]];
        
        //5. 构建动态抽象祖母;
        AIAlgNodeBase* (^RelateDynamicAlgBlock)(AIAlgNodeBase*, AIAlgNode*,AIPointer*) = ^AIAlgNodeBase* (AIAlgNodeBase *dynamicAbsNode, AIAlgNode *conNode,AIPointer *value_p){
            if (ISOK(dynamicAbsNode, AIAbsAlgNode.class)) {
                ///1. 有效时,关联;
                [AINetUtils relateAbs:(AIAbsAlgNode*)dynamicAbsNode conNodes:@[conNode] save:true];
            }else{
                ///2. 无效时,构建;
                if (value_p) {
                    dynamicAbsNode = [theNet createAbsAlgNode:@[value_p] alg:conNode];
                }
            }
            return dynamicAbsNode;
        };
        BOOL aThan = (compareResult == NSOrderedAscending);
        lessAlg = RelateDynamicAlgBlock(lessAlg,(aThan ? algB : algA),less_p);//从小到大
        greaterAlg = RelateDynamicAlgBlock(greaterAlg,(aThan ? algA : algB),greater_p);//从大到小
        
        //6. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
        if (lessAlg && greaterAlg) {
            NSMutableArray *absOrders = [[NSMutableArray alloc] init];
            [absOrders addObject:(aThan ? greaterAlg.pointer : lessAlg.pointer)];
            [absOrders addObjectsFromArray:rangeOrders];
            [absOrders addObject:(aThan ? lessAlg.pointer : greaterAlg.pointer)];
            return [theNet createAbsFo_Inner:conFo orderSames:absOrders];
        }
    }
    return nil;
}

/**
 *  MARK:--------------------内类比的内中有外--------------------
 *  1. 根据abFo联想assAbFo并进行外类比
 *  2. 复用外类比方法;
 */
+(AINetAbsFoNode*)analogyInner_Outside:(AINetAbsFoNode*)abFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)())updateEnergy{
    //1. 数据检查
    if (ISOK(abFo, AINetAbsFoNode.class)) {
        //2. 取用来联想的aAlg;
        AIPointer *a_p = ARR_INDEX(abFo.orders_kvp, 0);
        AIAlgNodeBase *aAlg = [SMGUtils searchObjectForPointer:a_p fileName:FILENAME_Node time:cRedisNodeTime];
        if (!aAlg) {
            return nil;
        }
        
        //3. 根据aAlg联想到的assAbFo时序;
        AIFoNodeBase *assAbFo = nil;
        for (AIPort *refPort in aAlg.refPorts) {
            ///1. 不能与abFo重复
            if (![aAlg.pointer isEqual:refPort.target_p]) {
                AIFoNodeBase *refFo = [SMGUtils searchObjectForPointer:refPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
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
            return nil;
        }
        
        //4. 对abFo和assAbFo进行类比;
        NSArray *orderSames = [self analogyOutsideOrdersA:abFo.orders_kvp ordersB:assAbFo.orders_kvp canAss:canAssBlock updateEnergy:updateEnergy];
        
        //5. 构建absAbFo
        AINetAbsFoNode *absAbFo = [theNet createAbsFo_Outside:abFo foB:assAbFo orderSames:orderSames];
        return absAbFo;
    }
    return nil;
}


@end
