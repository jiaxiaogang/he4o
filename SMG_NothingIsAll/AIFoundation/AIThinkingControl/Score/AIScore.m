//
//  AIScore.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/5.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIScore.h"

@implementation AIScore

//MARK:===============================================================
//MARK:                     < 下标不急评价 >
//MARK:===============================================================

/**
 *  MARK:--------------------下标不急(弄巧成拙)评价--------------------
 *  @desc
 *          1. 说明: R子任务来的及评价 (后续考虑支持rootR任务) (参考22194 & 22195 & 22198);
 *          2. 决策时序AB 在 任务未发生部分D 中找mIsC (找到AB中index,index及之后需要等待静默成功,之前的可实行行为化) (参考22198);
 *          3. 必要性: ARSTime来的及评价是针对某帧的,而决策中,外界条件会变化,所以必须每帧都单独评价;
 *  @param dsFoModel : 当前正在推进的解决方案,其中actionIndex为当前帧;
 *  @param demand : 当前任务;
 *  @result (参考22194示图 & 22198) (默认为ture);
 *      true    : 提前可预备部分:返回true以进行_hav实时行为化 (比如:在穿越森林前,在遇到老虎前,我们先带枪);
 *      false   : 来的及返回false则ActYes等待静默成功,并继续推进主任务 (比如:枪已取到,现在先穿越森林,等老虎出现时,再吓跑它);
 */
+(BOOL) ARS_Time:(TOFoModel*)dsFoModel demand:(ReasonDemandModel*)demand{
    //1. 找下标;
    __block NSInteger dsIndex = -1;
    __block NSInteger demandIndex = -1;
    [self score4ARSTime:dsFoModel demand:demand finishBlock:^(NSInteger _dsIndex, NSInteger _demandIndex) {
        dsIndex = _dsIndex;
        demandIndex = _demandIndex;
    }];
    
    //2. 下标有效时,返回ARSTime结果 (参考22194示图 & 22198);;
    if (demandIndex != -1) {
        //3a. ds下标后的dsFo部分,需要静默等待 (会导致弄巧成拙,评价为否->ActYes);
        //3b. ds下标前的dsFo部分,可直接行为化 (当dsAlg在demand预测中已发生时,评价为是->立马行为化修正);
        return dsFoModel.actionIndex < dsIndex;
    }
    return true;
}

/**
 *  MARK:--------------------来的及评分--------------------
 *  @desc 对dsFo的从前到后所有元素,在demand的预测中未发生的部分,找下标返回 (参考22198示图);
 *  @param finishBlock notnull : 根据dsFo的哪个下标,发现了在demand预测fo中的哪个下标,使用说明如下;
 */
+(void) score4ARSTime:(TOFoModel*)dsFoModel demand:(ReasonDemandModel*)demand finishBlock:(void(^)(NSInteger _dsIndex,NSInteger _demandIndex))finishBlock{
    //1. 数据检查;
    if (!dsFoModel || !demand) return;
    AIFoNodeBase *dsFo = [SMGUtils searchNode:dsFoModel.content_p];
    
    //2. 找下标 (参考注释@desc);
    for (NSInteger i = 0; i < dsFo.count; i++) {
        AIKVPointer *dsAlg_p = ARR_INDEX(dsFo.content_ps, i);
        NSInteger demandIndex = [TOUtils indexOfConOrAbsItem:dsAlg_p atContent:demand.mModel.matchFo.content_ps layerDiff:2 startIndex:demand.mModel.cutIndex2 + 1 endIndex:NSUIntegerMax];
        
        //3. 根据dsIndex发现demandIndex成功 (仅需发现一个下标即可);
        if (demandIndex != -1) {
            finishBlock(i,demandIndex);  //根据i发现了result
            return;
        }
    }
}

//MARK:===============================================================
//MARK:                     < 时间不急评价 >
//MARK:===============================================================

/**
 *  MARK:--------------------时间不急评价--------------------
 *  @desc 时间不急评价: 紧急情况 = 解决方案所需时间 > 父任务能给的时间 (参考:24057-方案3,24171-7);
 *  @version
 *      2022.01.19: 从action前置到rSolution中,因为三条全紧急,就完蛋了,放到action则不受此限制 (参考25106);
 *      2022.02.22: 将needTime取到mv改为仅取下帧,因为很多solution只需要一帧就改到正确的道路上了 (参考25113-方案2);
 *  @result 返回是否时间不急 (默认为true);
 *      true    : 不急,时间够用,这方案可继续act;
 *      false   : 紧急,这方案来不及执行,直接ActNo掉;
 */
+(BOOL) FRS_Time:(ReasonDemandModel*)demand solutionFo:(AIFoNodeBase*)solutionFo{
    //1. 取解决方案所需时间;
    int cutIndex = -1;//foModel.actionIndex
    double needTime = [TOUtils getSumDeltaTime:solutionFo startIndex:cutIndex endIndex:1];
    
    //2. 取父任务能给的时间;
    double giveTime = [TOUtils getSumDeltaTime2Mv:demand.mModel.matchFo cutIndex:demand.mModel.cutIndex2];
    
    //3. 判断是否时间不急;
    BOOL timeIsEnough = needTime <= giveTime;
    NSLog(@"\t时间不急==> 状态(%d) = 方案所需要时间:%.2f <= 任务能给时间:%.2f",timeIsEnough,needTime,giveTime);
    return timeIsEnough;
}

//MARK:===============================================================
//MARK:                     < MPS评分 >
//MARK:===============================================================
//MPS评分
+(CGFloat) score4MV:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio{
    AICMVNodeBase *cmvNode = [SMGUtils searchNode:cmvNode_p];
    if (ISOK(cmvNode, AICMVNodeBase.class)) {
        return [AIScore score4MV:cmvNode.pointer.algsType urgentTo_p:cmvNode.urgentTo_p delta_p:cmvNode.delta_p ratio:ratio];
    }
    return 0;
}
+(CGFloat) score4MV:(NSString*)algsType urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p ratio:(CGFloat)ratio{
    //1. 检查absCmvNode是否顺心
    NSInteger delta = [NUMTOOK([AINetIndex getData:delta_p]) integerValue];
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];
    return [self score4MV:algsType urgentTo:urgentTo delta:delta ratio:ratio];
}
+(CGFloat) score4MV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta ratio:(CGFloat)ratio{
    //1. 检查absCmvNode是否顺心
    BOOL havDemand = [ThinkingUtils havDemand:algsType delta:delta];
    
    //2. 根据检查到的数据取到score;
    ratio = MIN(1,MAX(ratio,0));
    if (havDemand) {
        return  -urgentTo * ratio;
    }else{
        return urgentTo * ratio;
    }
}

/**
 *  MARK:--------------------对预测价值时序评分V2--------------------
 *  @desc score = spScore * mvScore (即将原匹配度,改为由spScore来替代);
 *  @result 1. 返回评分越低说明越不好,越高越好;
 *          2. 返回正值为正mv,返回负值为负mv;
 */
+(CGFloat) score4MV_v2:(AIMatchFoModel*)inModel{
    BOOL isBadMv = [ThinkingUtils havDemand:inModel.matchFo.cmvNode_p];
    CGFloat spScore = [TOUtils getSPScore:inModel.matchFo startSPIndex:inModel.cutIndex2 + 1 endSPIndex:inModel.matchFo.count];
    CGFloat ratio = isBadMv ? (1 - spScore) : spScore;
    return [AIScore score4MV:inModel.matchFo.cmvNode_p ratio:ratio];//价值迫切度 * 匹配度
}
+(CGFloat) score4Demand:(DemandModel*)demand{
    if (ISOK(demand, ReasonDemandModel.class) ) {
        return [AIScore score4MV_v2:((ReasonDemandModel*)demand).mModel];
    }else{
        HDemandModel *hdemand;
        hdemand.
    }
    BOOL isBadMv = [ThinkingUtils havDemand:inModel.matchFo.cmvNode_p];
    CGFloat spScore = [TOUtils getSPScore:inModel.matchFo startSPIndex:inModel.cutIndex2 + 1 endSPIndex:inModel.matchFo.count];
    CGFloat ratio = isBadMv ? (1 - spScore) : spScore;
    return [AIScore score4MV:inModel.matchFo.cmvNode_p ratio:ratio];//价值迫切度 * 匹配度
}

//MARK:===============================================================
//MARK:                     < MPS评价 >
//MARK:===============================================================

//同区且同向
+(BOOL) sameIdenSameScore:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    if ([self sameIdentifierOfMV1:mv1_p mv2:mv2_p]) {
        CGFloat mScore = [AIScore score4MV:mv1_p ratio:1.0f];
        CGFloat sScore = [AIScore score4MV:mv2_p ratio:1.0f];
        return [self sameDire:mScore v2:sScore];
    }
    return false;
}

//同区不同向
+(BOOL) sameIdenNoSameScore:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    CGFloat ratio = 1.0f;
    return [self sameIdentifierOfMV1:mv1_p mv2:mv2_p] && ![self sameDire:Mvp2Score(mv1_p, ratio) v2:Mvp2Score(mv2_p, ratio)];
}

//同区且同向
+(BOOL) sameIdenSameDelta:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    return [self sameIdentifierOfMV1:mv1_p mv2:mv2_p] && [self sameDire:Mvp2Delta(mv1_p) v2:Mvp2Delta(mv2_p)];
    return false;
}

//同区且反向
+(BOOL) sameIdenDiffDelta:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    return [self sameIdentifierOfMV1:mv1_p mv2:mv2_p] && [self diffDire:Mvp2Delta(mv1_p) v2:Mvp2Delta(mv2_p)];
}

//MARK:===============================================================
//MARK:                     < 单纯同区同向判断 >
//MARK:===============================================================
//同区
+(BOOL) sameIdentifierOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    return mv1_p && mv2_p && [mv1_p.identifier isEqualToString:mv2_p.identifier];
}
//同向
+(BOOL) sameDire:(NSInteger)v1 v2:(NSInteger)v2{
    return (v1 > 0 && v2 > 0) || (v1 < 0 && v2 < 0);
}
//反向
+(BOOL) diffDire:(NSInteger)v1 v2:(NSInteger)v2{
    return (v1 > 0 && v2 < 0) || (v1 < 0 && v2 > 0);
}

@end
