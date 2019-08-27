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
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy fromInner:(BOOL)fromInner{
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
                    AIAlgNodeBase *algNodeA = [SMGUtils searchNode:algNodeA_p];
                    AIAlgNodeBase *algNodeB = [SMGUtils searchNode:algNodeB_p];
                    
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
                            AIAbsAlgNode *createAbsNode = [theNet createAbsAlgNode:sameValue_ps conAlgs:@[algNodeA,algNodeB] isMem:false];
                            if (createAbsNode) {
                                [orderSames addObject:createAbsNode.pointer];
                            }
                            ///4. 构建时,消耗能量值;
                            if (updateEnergy) {
                                updateEnergy(-0.1f);
                            }
                        }
                    }
                    
                    ///5. absPorts->orderSames (根据强度优先)190827注掉,因为此处抽象不必添加到新时序中,且已经取消概念嵌套,所以还是以上面sameValue_ps构建的新absAlg添加进去即可;
                    //NSMutableArray *aAbsPorts = [[NSMutableArray alloc] init];
                    //[aAbsPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:algNodeA.pointer fileName:kFNMemAbsPorts time:cRTMemPort]];
                    //[aAbsPorts addObjectsFromArray:algNodeA.absPorts];
                    //
                    //NSMutableArray *bAbsPorts = [[NSMutableArray alloc] init];
                    //[bAbsPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:algNodeB.pointer fileName:kFNMemAbsPorts time:cRTMemPort]];
                    //[bAbsPorts addObjectsFromArray:algNodeB.absPorts];
                    //
                    //for (AIPort *aPort in aAbsPorts) {
                    //    for (AIPort *bPort in bAbsPorts) {
                    //        if ([aPort.target_p isEqual:bPort.target_p]) {
                    //            [orderSames addObject:bPort.target_p];
                    //            break;
                    //        }
                    //    }
                    //}
                }
            }
        }
    }

    //3. 外类比构建
    if (orderSames.count == 1) {
        NSLog(@"将构建长度为1的时序, fo:%lu,assFo:%lu",(unsigned long)fo.orders_kvp.count,(unsigned long)assFo.orders_kvp.count);
        [theNV setNodeData:fo.pointer lightStr:@"BugFrom"];
        [theNV setNodeData:assFo.pointer lightStr:@"BugFrom"];
        NSLog(@"");
    }
    [self analogyOutside_Creater:orderSames fo:fo assFo:assFo fromInner:fromInner];
}

/**
 *  MARK:--------------------外类比的构建器--------------------
 *  1. 构建absFo
 *  2. 构建absCmv
 */
+(void)analogyOutside_Creater:(NSArray*)orderSames fo:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo fromInner:(BOOL)fromInner{
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
            if (!fromInner) {
                AICMVNodeBase *assMv = [SMGUtils searchNode:assFo.cmvNode_p];
                if (assMv) {
                    AIAbsCMVNode *createAbsCmv = [theNet createAbsCMVNode_Outside:createAbsFo.pointer aMv_p:fo.cmvNode_p bMv_p:assMv.pointer];
                    
                    //6. cmv模型连接;
                    if (ISOK(createAbsCmv, AIAbsCMVNode.class)) {
                        createAbsFo.cmvNode_p = createAbsCmv.pointer;
                        [SMGUtils insertObject:createAbsFo pointer:createAbsFo.pointer fileName:kFNNode time:cRTNode];
                    }
                    
                    //[theNV setNodeData:createAbsFo.pointer];
                    //调试时序中,仅有"吃"的问题;
                    if (createAbsFo.orders_kvp.count == 1) {
                        AIAlgNodeBase *algNode = [SMGUtils searchNode:ARR_INDEX(createAbsFo.orders_kvp, 0)];
                        if (algNode && algNode.pointer.isOut) {
                            NSLog(@"警告!! BUGFrom->BUG 时序中,仅有一个输出节点");
                        }
                    }
                    
                    [theNV setNodeData:createAbsFo.pointer lightStr:@"新抽"];
                    [theNV setNodeData:createAbsCmv.pointer lightStr:@"新抽"];
                    //TODOTOMORROW:发现BUG,此处assFo和createAbsFo的时序内容是一致的;
                    //应该加强,而不是再构建一个新的,导致构建多个;(此时时序为29 -abs-> 33 -abs-> 41,37)
                    //硬盘的已通过修改createAbsAlg()修复,内存的,还未修复,,,
                }
            }
        }
    }
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================
+(void) analogyInner:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
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
                //训练距离:
//                *      1. 点击一下,马上饿,产生demand和energy;
//                *      2. 远投一个坚果;
//                *      3. 点击摸翅膀,让鸟在触摸反射动下,和坚果距离产生变化;
//                *      4. 直投,让鸟在时序中,意识到靠飞行,来距离变化,(调试内类比构建);
                
                //测到问题:依次点击后,最终却构建了radius的变化,而不是距离变化;
                //测到问题:有时序,指向了hungerMv+,但其并不能解决饥饿问题;
                //测到问题:在点马上饿,TO输出了"吃" (说明在认知过程中,有了过份抽象的问题);
                
                return;
            }
            
            //4. 取出两个概念
            AIKVPointer *algA_p = ARR_INDEX(orders, i);
            AIKVPointer *algB_p = ARR_INDEX(orders, j);
            AIAlgNode *algNodeA = [SMGUtils searchNode:algA_p];
            AIAlgNode *algNodeB = [SMGUtils searchNode:algB_p];
            
            //5. 内类比找不同 (比大小:同区不同值 / 有无)
            AINetAbsFoNode *abFo = nil;
            NSString *lightStr = nil;
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
                    NSLog(@"inner > 大小 %@,%@",a_p.folderName,b_p.folderName);
                    if ([a_p.identifier isEqualToString:b_p.identifier] && [kPN_VALUE isEqualToString:b_p.folderName]) {
                        //注: 对比微信息是否不同 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
                        if (a_p.pointerId != b_p.pointerId) {
                            [theApp.nvView setNodeData:algNodeA.pointer];
                            [theApp.nvView setNodeData:algNodeB.pointer];
                            NSNumber *numA = [AINetIndex getData:a_p];
                            NSNumber *numB = [AINetIndex getData:b_p];
                            NSLog(@"inner > 构建变化,%@:%@->%@",a_p.dataSource,numA,numB);
                            NSComparisonResult compareResult = [NUMTOOK(numA) compare:NUMTOOK(numB)];
                            if (compareResult == NSOrderedAscending) {
                                abFo = [self analogyInner_Creater:AnalogyInnerType_Less target_p:a_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                                lightStr = @"小";
                            }else if (compareResult == NSOrderedDescending) {
                                abFo = [self analogyInner_Creater:AnalogyInnerType_Greater target_p:a_p algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                                lightStr = @"大";
                            }
                        }
                    }
                }else if(aSub_ps.count > 0 && bSub_ps.count == 0){
                    //2) 当长度各aSub>0和bSub=0时,抽象出aSub,并构建其"有变无"时序;
                    AIAbsAlgNode *targetNode = [theNet createAbsAlgNode:aSub_ps conAlgs:@[algNodeA] isMem:false];
                    NSLog(@"inner > 构建无,%@",targetNode.pointer.identifier);
                    abFo = [self analogyInner_Creater:AnalogyInnerType_None target_p:targetNode.pointer algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                    lightStr = @"无";
                }else if(aSub_ps.count == 0 && bSub_ps.count > 0){
                    //3) 当长度各aSub=0和bSub>0时,抽象出bSub,并构建其"无变有"时序;
                    AIAbsAlgNode *targetNode = [theNet createAbsAlgNode:aSub_ps conAlgs:@[algNodeB] isMem:false];
                    NSLog(@"inner > 构建有,%@",targetNode.pointer.identifier);
                    abFo = [self analogyInner_Creater:AnalogyInnerType_Hav target_p:targetNode.pointer algA:algNodeA algB:algNodeB rangeOrders:rangeOrders conFo:checkFo];
                    lightStr = @"有";
                }
            }
            
            //6. 对energy消耗;
            if (!ISOK(abFo, AINetAbsFoNode.class)) {
                continue;
            }
            if (updateEnergy) {
                updateEnergy(-1.0f);
            }
            
            //7. 内中有外
            [theNV setNodeData:abFo.pointer];
            [theNV lightNode:abFo.pointer str:lightStr];
            [self analogyInner_Outside:abFo canAss:canAssBlock updateEnergy:updateEnergy];
        }
    }
}


/**
 *  MARK:--------------------内类比的构建方法--------------------
 *  @param type : 内类比类型,大小有无; (必须为四值之一,否则构建未知节点)
 *  @param target_p : 目前正在操作的指针; (可能是微信息指针,也可能是被嵌套的概念指针)
 *  @param rangeOrders : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 *
 *  > 作用
 *  1. 构建动态微信息;
 *  2. 构建动态概念;
 *  3. 构建abFoNode时序;
 *  4. 构建mv节点;
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyInnerType)type target_p:(AIKVPointer*)target_p algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB rangeOrders:(NSArray*)rangeOrders conFo:(AIFoNodeBase*)conFo{
    NSLog(@"inner > 内类比,构建器执行构建");
    //1. 数据检查
    rangeOrders = ARRTOOK(rangeOrders);
    if (target_p && algA && algB) {
        
        //2. 根据type来构建微信息,和概念; (将a和b改成前和后)
        BOOL isHavNon = (type == AnalogyInnerType_Hav || type == AnalogyInnerType_None);
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
        AIPointer *frontValue_p = [theNet getNetDataPointerWithData:@(frontData) algsType:target_p.algsType dataSource:target_p.dataSource];
        AIPointer *backValue_p = [theNet getNetDataPointerWithData:@(backData) algsType:target_p.algsType dataSource:target_p.dataSource];
        if (!frontValue_p || !backValue_p) {
            return nil;
        }
        
        //4. 取出绝对匹配的dynamic抽象概念
        AIAlgNodeBase *frontAlg = [theNet getAbsoluteMatchingAlgNodeWithValueP:frontValue_p];
        AIAlgNodeBase *backAlg = [theNet getAbsoluteMatchingAlgNodeWithValueP:backValue_p];
        
        //5. 构建动态抽象概念block;
        AIAlgNodeBase* (^RelateDynamicAlgBlock)(AIAlgNodeBase*, AIAlgNodeBase*,AIPointer*) = ^AIAlgNodeBase* (AIAlgNodeBase *dynamicAbsNode, AIAlgNodeBase *conNode,AIPointer *value_p){
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
        
        //5. 构建"有无"抽象概念; (有无时,以"变有无的那个概念"为具象)
        if (isHavNon) {
            AIAlgNodeBase *conNode = [SMGUtils searchNode:target_p];
            frontAlg = RelateDynamicAlgBlock(frontAlg,conNode,frontValue_p);
            backAlg = RelateDynamicAlgBlock(backAlg,conNode,backValue_p);
        }else{
            //5. 构建"大小"抽象概念; (大小时,以"微信息所在的概念"为具象)
            //20190809注:此处可考虑,不做具象指向,因为大小概念,本来就是独立的节点;
            frontAlg = RelateDynamicAlgBlock(frontAlg,algA,frontValue_p);
            backAlg = RelateDynamicAlgBlock(backAlg,algB,backValue_p);
        }
        
        //6. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
        if (frontAlg && backAlg) {
            NSMutableArray *absOrders = [[NSMutableArray alloc] init];
            [absOrders addObject:frontAlg.pointer];
            [absOrders addObjectsFromArray:rangeOrders];
            [absOrders addObject:backAlg.pointer];
            AINetAbsFoNode *createrFo = [theNet createAbsFo_Inner:conFo orderSames:absOrders];
            
            //190819取消理性fo(大小有无fo)指向mvNode;
            //if (!createrFo) {
            //    return nil;
            //}
            //
            ////7. 构建mv节点,形成mv基本模型;
            //AIAbsCMVNode *createrMv = [theNet createAbsCMVNode_Inner:createrFo.pointer conMv_p:conFo.cmvNode_p];
            //
            ////8. cmv模型连接;
            //if (ISOK(createrMv, AIAbsCMVNode.class)) {
            //    createrFo.cmvNode_p = createrMv.pointer;
            //    [SMGUtils insertNode:createrFo];
            //}
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
+(void)analogyInner_Outside:(AINetAbsFoNode*)abFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
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
        [theNV setNodeData:assAbFo.pointer];
        [self analogyOutside:abFo assFo:assAbFo canAss:canAssBlock updateEnergy:updateEnergy fromInner:true];
    }
}

@end
