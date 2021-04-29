//
//  AIScore.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/5.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIScore.h"
#import "AINetService.h"
#import "AIPort.h"
#import "AINetIndex.h"
#import "TOUtils.h"
#import "AINetUtils.h"
#import "AIShortMatchModel.h"
#import "ThinkingUtils.h"
#import "DemandModel.h"
#import "TOFoModel.h"
#import "AIAlgNodeBase.h"
#import "AIMatchFoModel.h"
#import "ReasonDemandModel.h"

@implementation AIScore

//MARK:===============================================================
//MARK:                     < VRS评价 >
//MARK:===============================================================

/**
 *  MARK:--------------------VRS评价--------------------
 *  @desc 值域求和V2: 束波求和简化版,采取线函数来替代找交点 (参考21212 & 21213);
 *  @param sPorts : 传入Alg.ATSub的端口组;
 *  @result <-2 时评价为否 (参考22025-分析2);
 *  @todo
 *      2021.01.01: 在排序后对同值的元素抵消(s3+p5=p2) (先不实现,因为同值此时交点即会直接取到值,在评价时,似乎这样并没有什么问题);
 *  @version
 *      2021.01.02: 解决sort未被接收,导致排序不生效的BUG;
 *      2021.01.02: 支持maskIdentifier,因为原来把alg当成value来取值,导致生成sumModels和评价完全错误 (参考21216);
 *      2021.01.10: v2迭代,由偶发性导致的评价BUG引出迭代 (参考n22p2);
 *      2021.01.10: v2迭代,之直线范围累计法 (参考22025-方案5);
 *      2021.01.14: 改为根据是否有同区码决定默认评价结果,起因:稀有值无法评价的问题 (参考22034-代码);
 */
+(BOOL) VRS:(AIKVPointer*)value_p cAlg:(AIAlgNodeBase*)cAlg sPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts {
    //1. value_p与cAlg是否有同区码判定;
    BOOL findSameIden = ARRISOK([SMGUtils filterPointers:cAlg.content_ps identifier:value_p.identifier]);
    
    //2. 有同区码时默认为false,无时默认为true (参考22034);
    BOOL result = !findSameIden;
    
    //3. 对sp评分
    if (Log4VRS_Main) NSLog(@"============== VRS ==============%@\nfrom:%@ 有同区码:%@",Pit2FStr(value_p),Alg2FStr(cAlg),findSameIden?@"是":@"否");
    double sScore = [self score4Value:value_p spPorts:sPorts];
    double pScore = [self score4Value:value_p spPorts:pPorts];
    
    //4. 评价 (容错区间为2) (参考22034 & 22025-分析2);
    if (sScore - pScore >= 2) {
        result = false;
    }else if (pScore - sScore >= 2) {
        result = true;
    }
    if (Log4VRS_Main) NSLog(@"----> S评分:%@ P评分:%@ 评价结果:%@",STRFORMAT(@"%.2f",sScore),STRFORMAT(@"%.2f",pScore),result?@"通过":@"未通过");
    return result;
}
//VRS评分
+(double) score4Value:(AIKVPointer*)value_p spPorts:(NSArray*)spPorts {
    //1. 数据准备;
    double result = 0;
    spPorts = ARRTOOK([SMGUtils filterAlgPorts:spPorts valueIdentifier:value_p.identifier]);
    if (!value_p || !ARRISOK(spPorts)) return result;
    double value = [NUMTOOK([AINetIndex getData:value_p]) doubleValue];
    NSString *valueIden = value_p.identifier;
    
    //2. 从小到大排序;
    NSArray *sortPorts = [spPorts sortedArrayUsingComparator:^NSComparisonResult(AIPort *p1, AIPort *p2) {
        double v1 = [AINetService getValueDataFromAlg:p1.target_p valueIdentifier:valueIden];
        double v2 = [AINetService getValueDataFromAlg:p2.target_p valueIdentifier:valueIden];
        return [SMGUtils compareFloatA:v2 floatB:v1];
    }];
    
    //3. 找出max-min (影响范围为1/3,一边一半);
    AIPort *minPort = ARR_INDEX(sortPorts, 0);
    AIPort *maxPort = ARR_INDEX_REVERSE(sortPorts, 0);
    double minValue = [AINetService getValueDataFromAlg:minPort.target_p valueIdentifier:valueIden];
    double maxValue = [AINetService getValueDataFromAlg:maxPort.target_p valueIdentifier:valueIden];
    double scope = (maxValue - minValue) / 3.0f / 2.0f;
    
    //4. 累计 (参考22025评分图);
    for (AIPort *item in sortPorts) {
        double itemValue = [AINetService getValueDataFromAlg:item.target_p valueIdentifier:valueIden];
        double distance = fabs(itemValue - value);
        if (distance <= scope) {
            double rate = scope > 0 ? (scope - distance) / scope : 1.0f;
            double itemStrong = rate * item.strong.value;
            result += itemStrong;
            if (Log4VRS_Desc) NSLog(@"-> %@ 新增: %@ x %ld = %@ 累计:%f 依据:%@",ATType2Str([item.target_p.dataSource integerValue]),STRFORMAT(@"%.2f",rate),(long)item.strong.value,STRFORMAT(@"%.2f",itemStrong),result,Pit2FStr(item.target_p));
        }
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < FRS >
//MARK:===============================================================

/**
 *  MARK:--------------------未发生理性评价 (空S)--------------------
 *  @version
 *      2021.01.23: 兼容isSP类型,以支持R-模式下的空S评价 (参考22061-1);
 *      2021.01.23: 原来判空方式为SPorts数组是否为空,会导致一次否定,永远否定,改为真正指向内容是否为空 T;
 *      2021.02.05: 非HNGLSP的时序,也进行空S评价,因为R-模式时,经常有单纯的上下飞解决方案来躲避,而不是解决"距Y"的问题才飞的;
 *  @todo
 *      2021.01.29: FRS.SP评价受基conFo.mv影响迭代 (参考22013);
 *      2021.04.23: 空S要考虑使用可行率对ports排名,而不是一棍子打死,终身牛逼,失误一次,打入地狱,太误杀 (参考22014);
 *  @result 默认返回true (因为空fo并不指向空S);
 */
+(BOOL) FRS:(AIFoNodeBase*)fo{
    //1. 未发生理性评价-必须为hnglsp节点 (否则F14主解决方案也会失败);
    //if (![TOUtils isHNGLSP:fo.pointer]) return true;
        
    //2. 未发生理性评价-且为空ATSub时,评价不通过;
    NSArray *sPorts = [AINetUtils absPorts_All:fo type:ATSub];
    NSString *spaceHeader = [NSString md5:@""];
    
    //3. 判断sPorts有没有空S (有时返回false,评价不通过);
    for (AIPort *sPort in sPorts) {
        if ([sPort.header isEqualToString:spaceHeader]) {
            return false;
        }
    }
    return true;
}

/**
 *  MARK:--------------------时序错过评价--------------------
 *  @desc
 *      1. 车已经撞了,再去修正Y距离,已经太晚了;
 *      2. 蚊子天天咬人,某天才把蚊子干掉,但依然是有效的 (所以我们只是防止其再一次发生);
 *      3. 综上: 这种FRS_Miss评价其实是无意义的,因为时序是否会再一次发生,这是另一个问题了;
 *  @status 废弃,是否Miss,这是后天习得的,不可以写成先天代码;
 */
+(BOOL) FRS_Miss:(AIFoNodeBase*)sFo matchFo:(AIFoNodeBase*)matchFo cutIndex:(NSInteger)cutIndex{
    //1. 数据检查;
    if (sFo && matchFo) {
        for (AIKVPointer *item in sFo.content_ps) {
            NSInteger index = [TOUtils indexOfAbsItem:item atConContent:matchFo.content_ps];
            if (index != -1) {
                //2. 发现item时,返回是否已错过 (cutIndex刚发生也不行);
                return cutIndex >= index;
            }
        }
    }
    //3. 默认未错过;
    return true;
}

/**
 *  MARK:--------------------时序来的及评价--------------------
 *  @desc 对将要决策部分:B 和 已发生部分:C 之间进行mIsC判断 (B<=C=已错过) (参考22197);
 *  @result
 *      true    : 继续行为化 (比如:没错过,正常继续即可);
 *      false   : 已错过即:将任务推进到已发生处 (比如:穿越森林任务出门前带枪,但已经出门了,枪已经忘带);
 */
+(BOOL) FRS_Time:(TOFoModel*)toFo demand:(ReasonDemandModel*)demand{
    //1. 数据检查;
    if (!toFo || !demand) return true;
    AIFoNodeBase *curFo = [SMGUtils searchNode:toFo.content_p];
    
    //2. 对将要决策部分:B 和 已发生部分:C 之间进行mIsC判断;
    for (NSInteger i = toFo.actionIndex + 1; i < curFo.count; i++) {
        AIKVPointer *alg_p = ARR_INDEX(curFo.content_ps, i);
        NSInteger findIndex = [TOUtils indexOfConOrAbsItem:alg_p atContent:demand.mModel.matchFo.content_ps layerDiff:2 startIndex:0 endIndex:demand.mModel.cutIndex];
        if (findIndex != -1) {
            //3. B < C = 已错过;
            return findIndex <= demand.mModel.cutIndex;
        }
    }
    return true;
}

//MARK:===============================================================
//MARK:                     < FPS >
//MARK:===============================================================

/**
 *  MARK:--------------------对TOFoModel进行反思评价--------------------
 *  @version
 *      2021.01.24: 对多时序识别,更准确多元的评价支持 (参考22073-todo2);
 *      2021.03.28: 对子任务已决策成功时,不计分 (参考22193);
 */
+(BOOL) FPS:(TOFoModel*)outModel rtInModel:(AIShortMatchModel*)rtInModel{
    //1. 数据检查
    if (!outModel || !rtInModel) {
        return true;
    }
    
    //2. 对mModel进行评价;
    CGFloat sumScore = 0;
    int sumCount = 0;
    for (AIMatchFoModel *item in rtInModel.matchPFos) {
        
        //3. item子任务已决策成功时,不计分;
        BOOL subDemandSuccess = false;
        for (ReasonDemandModel *demand in outModel.subDemands) {
            if ([demand.content_p isEqual:item.matchFo.pointer]) {
                subDemandSuccess = demand.status == TOModelStatus_Finish || demand.status == TOModelStatus_ActYes;
            }
        }
        if (subDemandSuccess) continue;
        
        //4. 需计分的,累计总分;
        CGFloat score = [AIScore score4MV:item.matchFo.cmvNode_p ratio:item.matchFoValue];
        sumScore += score;
        sumCount++;
    }
    CGFloat rtScore = rtInModel.matchPFos.count == 0 ? 0 : sumScore / sumCount;
    
    //3. 对demand进行评价 (P-模式下demand为负分);
    DemandModel *demand = [TOUtils getDemandModelWithSubOutModel:outModel];
    CGFloat demandScore = [AIScore score4MV:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
    
    //10. 如果mv同区,只要为负则失败;
    //if ([rtMv_p.algsType isEqualToString:demand.algsType] && [mMv_p.dataSource isEqualToString:cMv_p.dataSource] && mcScore < 0) { return false; }
    
    //4. 如果不同区,对mcScore和curScore返回评价值进行类比 (如宁饿死不吃屎);
    return rtScore > demandScore * 0.5f;
}

//MARK:===============================================================
//MARK:                     < ARS >
//MARK:===============================================================

/**
 *  MARK:--------------------概念理性评价--------------------
 *  @desc
 *      1. 采用空SAlg评价;
 *      2. 举例
 *          a. 食物能吃,猫粮是食物,但猫粮不能吃;
 *          b. 被物体撞会疼,坚果是物体,但撞到不会疼;
 *  @status 暂无需支持,后续需支持时写下,并集成到_Hav后,或者PM中;
 */
+(BOOL) ARS{
    return true;
}

/**
 *  MARK:--------------------概念来的及评价--------------------
 *  @desc
 *          1. 说明: R子任务来的及评价 (后续考虑支持rootR任务) (参考22194 & 22195 & 22198);
 *          2. 决策时序AB 在 任务未发生部分D 中找mIsC (找到AB中index,index及之后需要等待静默成功,之前的可实行行为化) (参考22198);
 *          3. 必要性: ARSTime来的及评价是针对某帧的,而决策中,外界条件会变化,所以必须每帧都单独评价;
 *  @param dsFo : 当前正在推进的解决方案,其中actionIndex为当前帧;
 *  @param demand : 当前任务;
 *  @result (参考22194示图 & 22198);
 *      true    : 提前可预备部分:返回true以进行_hav实时行为化 (比如:在穿越森林前,在遇到老虎前,我们先带枪);
 *      false   : 来的及返回false则ActYes等待静默成功,并继续推进主任务 (比如:枪已取到,现在先穿越森林,等老虎出现时,再吓跑它);
 */
+(BOOL) ARS_Time:(TOFoModel*)dsFo demand:(ReasonDemandModel*)demand{
    //1. 数据检查;
    if (!dsFo || !demand) return true;
    AIFoNodeBase *curFo = [SMGUtils searchNode:dsFo.content_p];
    
    //2. 当dsAlg会导致弄巧成拙时,评价为否->ActYes;
    for (NSInteger i = 0; i < curFo.count; i++) {
        AIKVPointer *alg_p = ARR_INDEX(curFo.content_ps, i);
        NSInteger findIndex = [TOUtils indexOfConOrAbsItem:alg_p atContent:demand.mModel.matchFo.content_ps layerDiff:2 startIndex:demand.mModel.cutIndex + 1 endIndex:NSUIntegerMax];
        if (findIndex != -1) {
            //3. ARSTime结果 (参考22194示图 & 22198);
            return dsFo.actionIndex < i;
        }
    }
    return true;
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
    MindHappyType type = [ThinkingUtils checkMindHappy:algsType delta:delta];
    
    //2. 根据检查到的数据取到score;
    ratio = MIN(1,MAX(ratio,0));
    if (type == MindHappyType_Yes) {
        return urgentTo * ratio;
    }else if(type == MindHappyType_No){
        return  -urgentTo * ratio;
    }
    return 0;
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
