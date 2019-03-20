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
+(NSArray*) analogyOutsideOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock buildAlgNode:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))buildAlgNodeBlock{
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
                    ///1. 则检查能量值;
                    if (!canAssBlock || !canAssBlock()) {
                        break;
                    }
                    
                    ///2. 能量值足够,则取出algNodeA & algNodeB
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
                        if (buildAlgNodeBlock && ARRISOK(algSames)) {
                            buildAlgNodeBlock(algSames,algNodeA,algNodeB);
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
+(void) analogyInnerOrders:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock{
    //1. 数据检查
    if (!ISOK(checkFo, AIFoNodeBase.class)) {
        return;
    }
    NSArray *orders = ARRTOOK(checkFo.orders_kvp);
    
    //2. 取出两个祖母 (每个元素,分别与orders后面所有元素进行类比)
    for (NSInteger i = 0; i < orders.count; i++) {
        for (NSInteger j = i + 1; j < orders.count; j++) {
            AIKVPointer *algA_p = ARR_INDEX(orders, i);
            AIKVPointer *algB_p = ARR_INDEX(orders, j);
            AIAlgNode *algNodeA = [SMGUtils searchObjectForPointer:algA_p fileName:FILENAME_Node time:cRedisNodeTime];
            AIAlgNode *algNodeB = [SMGUtils searchObjectForPointer:algB_p fileName:FILENAME_Node time:cRedisNodeTime];
            
            //3. 内类比找不同 (同区不同值)
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
            
            //4. 内类比构建 (有且仅有1条微信息不同);
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
            
            //5. 内中有外 (根据abFo联想assAbFo并进行外类比) (尽量对外类比进行复用)
            if (ISOK(abFo, AINetAbsFoNode.class)) {
                ///1. 取用来联想的aAlg;
                AIPointer *a_p = ARR_INDEX(abFo.orders_kvp, 0);
                AIAlgNodeBase *aAlg = [SMGUtils searchObjectForPointer:a_p fileName:FILENAME_Node time:cRedisNodeTime];
                if (!aAlg) {
                    return;
                }
                
                ///2. 根据aAlg联想到的assAbFo时序; (不能与abFo重复 & 必须符合aAlg在orders前面)
                AIFoNodeBase *assAbFo = nil;
                for (AIPort *refPort in aAlg.refPorts) {
                    if (![aAlg.pointer isEqual:refPort.target_p]) {
                        AIFoNodeBase *refFo = [SMGUtils searchObjectForPointer:refPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                        if (ISOK(refFo, AIFoNodeBase.class)) {
                            AIPointer *firstAlg_p = ARR_INDEX(refFo.orders_kvp, 0);
                            if ([a_p isEqual:firstAlg_p]) {
                                assAbFo = refFo;
                                break;
                            }
                        }
                    }
                }
                
                ///3. 对abFo和assAbFo进行类比;
                
                /////TODOTOMORROW:
                /////1. 对外类比进行重构,从而复用;
                /////2. 外类比中消耗energy的方法,要跳过,由内类比自行处理;
                
                
                
                
                //6. 对energy消耗;
                if (!canAssBlock || !canAssBlock()) {
                    return;
                }
            }
        }
    }
}


/**
 *  MARK:--------------------内类比的构建方法--------------------
 *  @param rangeOrders : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 */
+(AINetAbsFoNode*)analogyInnerOrders_Creater:(AIKVPointer*)valueA_p valueB_p:(AIKVPointer*)valueB_p algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB rangeOrders:(NSArray*)rangeOrders conFo:(AIFoNodeBase*)conFo{
    //1. 数据检查
    rangeOrders = ARRTOOK(rangeOrders);
    if (valueA_p && valueB_p && algA && algB) {
        
        //2. 取出dynamic抽象祖母 (祖母引用联想的方式去重)
        AIPointer *less_p = [theNet getNetDataPointerWithData:@(cLess) algsType:valueA_p.algsType dataSource:valueA_p.dataSource];
        AIPointer *greater_p = [theNet getNetDataPointerWithData:@(cGreater) algsType:valueA_p.algsType dataSource:valueA_p.dataSource];
        if (!less_p || !greater_p) {
            return nil;
        }
        AIAlgNodeBase *lessAlg = [theNet getAbsoluteMatchingAlgNodeWithValuePs:@[less_p]];
        AIAlgNodeBase *greaterAlg = [theNet getAbsoluteMatchingAlgNodeWithValuePs:@[greater_p]];
        
        //3. 类比
        NSNumber *numA = [SMGUtils searchObjectForPointer:valueA_p fileName:FILENAME_Value time:cRedisValueTime];
        NSNumber *numB = [SMGUtils searchObjectForPointer:valueB_p fileName:FILENAME_Value time:cRedisValueTime];
        NSComparisonResult compareResult = [NUMTOOK(numA) compare:numB];
        if (compareResult == NSOrderedSame) {
            return nil;
        }
        
        //4. 祖母_构建&关联器
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
        
        //5. 构建动态抽象祖母; (从小到大 / 从大到小)
        BOOL aThan = (compareResult == NSOrderedAscending);
        lessAlg = RelateDynamicAlgBlock(lessAlg,(aThan ? algB : algA),less_p);
        greaterAlg = RelateDynamicAlgBlock(greaterAlg,(aThan ? algA : algB),greater_p);
        
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

@end
