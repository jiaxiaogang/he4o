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
#import "AINetIndexUtils.h"
#import "ThinkingUtils.h"
#import "TIRUtils.h"
//temp
#import "NVHeUtil.h"

@implementation AIThinkInAnalogy

//MARK:===============================================================
//MARK:                     < 外类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo外类比--------------------
 *  @version
 *      20200215: 有序外类比: 将forin循环fo和assFo改为反序,并记录上次类比位置jMax (因出现了[果,果,吃,吃]这样的异常时序) 参考n18p11;
 */
+(void) analogyOutside:(AIFoNodeBase*)fo assFo:(AIFoNodeBase*)assFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy fromInner:(BOOL)fromInner{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (fo && assFo) {
        
        //2. 外类比有序进行 (记录jMax & 反序)
        NSInteger jMax = assFo.content_ps.count - 1;
        for (NSInteger i = fo.content_ps.count - 1; i >= 0; i--) {
            for (NSInteger j = jMax; j >= 0; j--) {
                AIKVPointer *algNodeA_p = fo.content_ps[i];
                AIKVPointer *algNodeB_p = assFo.content_ps[j];
                //2. A与B直接一致则直接添加 & 不一致则如下代码;
                if ([algNodeA_p isEqual:algNodeB_p]) {
                    [orderSames insertObject:algNodeA_p atIndex:0];
                    jMax = j - 1;
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
                                [orderSames insertObject:createAbsNode.pointer atIndex:0];
                                jMax = j - 1;
                                if (!fromInner) {
                                    [theNV setNodeData:createAbsNode.pointer lightStr:STRFORMAT(@"新%ld (%ld&%ld)",createAbsNode.content_ps.count,algNodeA.pointer.pointerId,algNodeB.pointer.pointerId)];
                                }
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
    //TODO; 在精细化训练第6步,valueSames长度为7,构建后从可视化去看,其概念长度却是0;
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
        BOOL samesEqualAssFo = orderSames.count == assFo.content_ps.count && [SMGUtils containsSub_ps:orderSames parent_ps:assFo.content_ps];
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
                        [theNV setNodeData:createAbsCmv.pointer appendLightStr:@"外Mv4"];
                    }
                }
            }
            
            //调试短时序; (先仅打外类比日志);
            if (!fromInner) {
                [theNV setNodeData:createAbsFo.pointer lightStr:STRFORMAT(@"新%ld (%ld&%ld)",createAbsFo.content_ps.count,fo.pointer.pointerId,assFo.pointer.pointerId)];
            }
            
            //调试关联强度
            [theNV lightLineStrong:fo.pointer nodeDataB:createAbsFo.pointer];
        }
    }
}


//MARK:===============================================================
//MARK:                     < 内类比部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------fo内类比 (内中有外,找不同算法)--------------------
 *  @param checkFo      : 要处理的fo.orders;
 *  @param canAssBlock  : energy判断器 (为null时,无限能量);
 *  @param updateEnergy : energy消耗器 (为null时,不消耗能量值);
 *
 *  1. 此方法对一个fo内的orders进行内类比,并将找到的变化进行抽象构建网络;
 *  2. 如: 绿瓜变红瓜,如远坚果变近坚果;
 *  3. 每发现一个有效变化目标,则构建2个absAlg和2个absFo; (参考n15p18内类比构建图)
 *  注: 目前仅支持一个微信息变化的规律;
 *  TODO: 将内类比的类比部分代码,进行单独PrivateMethod,然后与外类比中调用的进行复用;
 *  @desc 代码说明:
 *      1. "有无"的target需要去重,因为a3.identifier = a4.identifier,而a4需要外类比,所以去重才能联想到同质fo;
 *      2. "有无"在191030改成单具象节点 (因为坚果的抽象不是坚果皮) 参考179_内类比全流程回顾;
 *  @迭代记录:
 *      2020.03.24: 内类比多码支持 (大小支持多个稀疏码变大/小 & 有无支持match.absPorts中多个变有/无);
 */
+(void) analogyInner_FromTIR:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (ISOK(checkFo, AIFoNodeBase.class) && checkFo.content_ps.count >= 2) {
        //2. 最后一个元素,向前分别与orders后面所有元素进行类比
        for (NSInteger i = checkFo.content_ps.count - 2; i >= 0; i--) {
            [self analogyInner:checkFo aIndex:i bIndex:checkFo.content_ps.count - 1 canAss:canAssBlock updateEnergy:updateEnergy];
        }
    }
}
+(void) analogyInner_FromTIP:(AIFoNodeBase*)checkFo canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (ISOK(checkFo, AIFoNodeBase.class) && checkFo.content_ps.count >= 2) {
        //2. 每个元素,分别与orders后面所有元素进行类比
        for (NSInteger i = 0; i < checkFo.content_ps.count; i++) {
            for (NSInteger j = i + 1; j < checkFo.content_ps.count; j++) {
                [self analogyInner:checkFo aIndex:i bIndex:j canAss:canAssBlock updateEnergy:updateEnergy];
            }
        }
    }
}
+(void) analogyInner:(AIFoNodeBase*)checkFo aIndex:(NSInteger)aIndex bIndex:(NSInteger)bIndex canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy{
    //1. 数据检查
    if (!ISOK(checkFo, AIFoNodeBase.class)) {
        return;
    }
    NSArray *orders = ARRTOOK(checkFo.content_ps);
    
    //3. 检查能量值
    if (canAssBlock && !canAssBlock()) {
        //训练距离-测到问题:发现BUG:小鸟仅发现了速度变化,飞行方向变化,却没有发现距离变化;
        return;
    }
    
    //4. 取出两个概念
    AIKVPointer *algA_p = ARR_INDEX(orders, aIndex);
    AIKVPointer *algB_p = ARR_INDEX(orders, bIndex);
    AIAlgNode *algNodeA = [SMGUtils searchNode:algA_p];
    AIAlgNode *algNodeB = [SMGUtils searchNode:algB_p];
    
    //5. 内类比找不同 (比大小:同区不同值 / 有无)
    if (algNodeA && algNodeB){
        //a. 调试内类比开始
        NSMutableString *aMStr = [[NSMutableString alloc] init];
        NSMutableString *bMStr = [[NSMutableString alloc] init];
        for (AIKVPointer *item_p in algNodeA.content_ps) [aMStr appendFormat:@"%@,",[NVHeUtil getLightStr:item_p]];
        for (AIKVPointer *item_p in algNodeB.content_ps) [bMStr appendFormat:@"%@,",[NVHeUtil getLightStr:item_p]];
        NSLog(@"内类比: [%@] | [%@]",SUBSTR2INDEX(aMStr, aMStr.length - 1),SUBSTR2INDEX(bMStr, bMStr.length - 1));

        //b. 内类比大小;
        NSArray *rangeAlg_ps = ARR_SUB(orders, aIndex + 1, bIndex - aIndex - 1);
        [self analogyInner_GL:checkFo algA:algNodeA algB:algNodeB rangeAlg_ps:rangeAlg_ps createdBlock:^(AINetAbsFoNode *createFo) {
            //c. 消耗思维活跃度 & 内中有外
            if (updateEnergy) updateEnergy(-0.1f);
            [self analogyInner_Outside:createFo canAss:canAssBlock updateEnergy:updateEnergy];
        }];
        
        //d. 内类比有无;
        [self analogyInner_HN:checkFo algA:algNodeA algB:algNodeB rangeAlg_ps:rangeAlg_ps createdBlock:^(AINetAbsFoNode *createFo) {
            //e. 消耗思维活跃度 & 内中有外
            if (updateEnergy) updateEnergy(-0.1f);
            [self analogyInner_Outside:createFo canAss:canAssBlock updateEnergy:updateEnergy];
        }];
    }
}

/**
 *  MARK:--------------------内类比大小--------------------
 */
+(void) analogyInner_GL:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps createdBlock:(void(^)(AINetAbsFoNode *createFo))createdBlock{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    if (!algA || !algB) {
        return;
    }
    
    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:algB.content_ps parent_ps:algA.content_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:algA.content_ps parent_ps:algB.content_ps];
    
    //3. 找出ab同标识字典;
    NSMutableDictionary *sameIdentifier = [SMGUtils filterSameIdentifier_ps:aSub_ps b_ps:bSub_ps];
    
    //4. 分别进行比较大小并构建变化;
    for (NSData *key in sameIdentifier.allKeys) {
        AIKVPointer *a_p = DATA2OBJ(key);
        AIKVPointer *b_p = [sameIdentifier objectForKey:key];
        //a. 对比微信息 (MARK_VALUE:如微信息去重功能去掉,此处要取值再进行对比)
        NSNumber *numA = [AINetIndex getData:a_p];
        NSNumber *numB = [AINetIndex getData:b_p];
        NSComparisonResult compareResult = [NUMTOOK(numA) compare:NUMTOOK(numB)];
        //b. 调试a_p和b_p是否合格,应该同标识,同文件夹名称,不同pId;
        NSLog(@"内类比 (大小) 前: %@/%@=%ld(%f) | %@/%@=%ld(%f)",a_p.folderName,a_p.identifier,(long)a_p.pointerId,[numA doubleValue],b_p.folderName,b_p.identifier,(long)b_p.pointerId,[numB doubleValue]);
        if (compareResult == NSOrderedAscending) {
            //c. 构建小;
            AINetAbsFoNode *create = [self analogyInner_Creater:AnalogyInnerType_Less target_p:a_p frontConAlg:algA backConAlg:algB rangeAlg_ps:rangeAlg_ps conFo:checkFo];
            if (createdBlock) createdBlock(create);
            NSLog(@"内类比 (小) 后: %@=%ld",create.pointer.identifier,(long)create.pointer.pointerId);
        }else if (compareResult == NSOrderedDescending) {
            //d. 构建大;
            AINetAbsFoNode *create = [self analogyInner_Creater:AnalogyInnerType_Greater target_p:a_p frontConAlg:algA backConAlg:algB rangeAlg_ps:rangeAlg_ps conFo:checkFo];
            if (createdBlock) createdBlock(create);
            NSLog(@"内类比 (大) 后: %@=%ld",create.pointer.identifier,(long)create.pointer.pointerId);
        }
    }
}

/**
 *  MARK:--------------------内类比有无--------------------
 */
+(void) analogyInner_HN:(AIFoNodeBase*)checkFo algA:(AIAlgNodeBase*)algA algB:(AIAlgNodeBase*)algB rangeAlg_ps:(NSArray*)rangeAlg_ps createdBlock:(void(^)(AINetAbsFoNode *createFo))createdBlock{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    AIAlgNodeBase *aMatchAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algA];
    AIAlgNodeBase *bMatchAlg = [ThinkingUtils getMatchAlgWithProtoAlg:algB];
    if (!aMatchAlg || !bMatchAlg) {
        return;
    }
    NSArray *aMAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:aMatchAlg]];
    NSArray *bMAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:bMatchAlg]];
    
    //2. 取a差集和b差集;
    NSArray *aSub_ps = [SMGUtils removeSub_ps:bMAbs_ps parent_ps:aMAbs_ps];
    NSArray *bSub_ps = [SMGUtils removeSub_ps:aMAbs_ps parent_ps:bMAbs_ps];
    
    //3. a变无
    for (AIKVPointer *sub_p in aSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        AINetAbsFoNode *create = [self analogyInner_Creater:AnalogyInnerType_None target_p:target.pointer frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo];
        if (createdBlock) createdBlock(create);
        NSLog(@"内类比 (无):%@=%ld => %@=%ld",sub_p.identifier,(long)sub_p.pointerId,create.pointer.identifier,(long)create.pointer.pointerId);
    }
    
    //4. b变有
    for (AIKVPointer *sub_p in bSub_ps) {
        AIAlgNodeBase *target = [SMGUtils searchNode:sub_p];
        AINetAbsFoNode *create = [self analogyInner_Creater:AnalogyInnerType_Hav target_p:target.pointer frontConAlg:target backConAlg:target rangeAlg_ps:rangeAlg_ps conFo:checkFo];
        if (createdBlock) createdBlock(create);
        NSLog(@"内类比 (有):%@=%ld => %@=%ld",sub_p.identifier,(long)sub_p.pointerId,create.pointer.identifier,(long)create.pointer.pointerId);
    }
}

/**
 *  MARK:--------------------内类比构建器--------------------
 *  @param type : 内类比类型,大小有无; (必须为四值之一,否则构建未知节点)
 *  @param rangeAlg_ps  : 在i-j之间的orders; (如 "a1 balabala a2" 中,balabala就是rangeOrders)
 *  @param target_p     : 操作对象 (有无时为概念地址,大小时为稀疏码地址);
 *      1. 构建有无时,以变有/无的概念为target;
 *      2. 构建大小时,以a_p/b_p为target (因为只是使用at&ds,所以用哪个都行);
 *  @param frontConAlg  :
 *      1. 构建有无时,以变有/无的概念为frontConAlg;
 *      2. 构建大小时,以"微信息所在的概念algA为frontConAlg;
 *  @param backConAlg   :
 *      1. 构建有无时,以变有/无的概念为backConAlg;
 *      2. 构建大小时,以"微信息所在的概念algB为backConAlg;
 *  @param conFo : 用来构建抽象具象时序时,作为具象节点使用;
 *  @作用
 *      1. 构建动态微信息;
 *      2. 构建动态概念;
 *      3. 构建abFoNode时序;
 */
+(AINetAbsFoNode*)analogyInner_Creater:(AnalogyInnerType)type target_p:(AIKVPointer*)target_p frontConAlg:(AIAlgNodeBase*)frontConAlg backConAlg:(AIAlgNodeBase*)backConAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo{
    //1. 数据检查
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    if (!target_p || !frontConAlg || !backConAlg || !conFo) return nil;
    
    //2. 获取front&back稀疏码值;
    NSInteger frontData = [TIRUtils getInnerFrontData:type];
    NSInteger backData = [TIRUtils getInnerFrontData:type];
    
    //3. 构建微信息;
    AIKVPointer *frontValue_p = [theNet getNetDataPointerWithData:@(frontData) algsType:target_p.algsType dataSource:target_p.dataSource];
    AIKVPointer *backValue_p = [theNet getNetDataPointerWithData:@(backData) algsType:target_p.algsType dataSource:target_p.dataSource];
    if (!frontValue_p || !backValue_p) {
        return nil;
    }
    
    //4. 构建抽象概念 (20190809注:此处可考虑,type为大/小时,不做具象指向,因为大小概念,本来就是独立的节点);
    AIAlgNodeBase *frontAlg = [TIRUtils createInnerAbsAlg:frontConAlg value_p:frontValue_p];
    AIAlgNodeBase *backAlg = [TIRUtils createInnerAbsAlg:backConAlg value_p:backValue_p];
    
    //5. 构建抽象时序; (小动致大 / 大动致小) (之间的信息为balabala)
    AINetAbsFoNode *result = [TIRUtils createInnerAbsFo:frontAlg backAlg:backAlg rangeAlg_ps:rangeAlg_ps conFo:conFo];
    
    //6. 调试内类比结果
    if (result) {
        NSMutableString *mStr = [[NSMutableString alloc] init];
        for (AIKVPointer *item_p in result.content_ps) [mStr appendFormat:@"%@=%ld,",item_p.identifier,(long)item_p.pointerId];
        NSString *typeDesc = (backData == cGreater) ? @"大" : (backData == cLess) ? @"小" : (backData == cHav) ? @"有" : (backData == cNone) ? @"无" : @"错误";
        NSLog(@"========> 内类比构建时序 (%@): [%@]",typeDesc,SUBSTR2INDEX(mStr, mStr.length - 1));
    }
    return result;
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
        AIPointer *a_p = ARR_INDEX(abFo.content_ps, 0);
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
                    AIPointer *firstAlg_p = ARR_INDEX(refFo.content_ps, 0);
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
