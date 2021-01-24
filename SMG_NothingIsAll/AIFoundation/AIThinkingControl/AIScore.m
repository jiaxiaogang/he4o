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
    if (Log4VRS) NSLog(@"============== VRS ==============%@\nfrom:%@ 有同区码:%@",Pit2FStr(value_p),Alg2FStr(cAlg),findSameIden?@"是":@"否");
    double sScore = [self score4Value:value_p spPorts:sPorts];
    double pScore = [self score4Value:value_p spPorts:pPorts];
    
    //4. 评价 (容错区间为2) (参考22034 & 22025-分析2);
    if (sScore - pScore >= 2) {
        result = false;
    }else if (pScore - sScore >= 2) {
        result = true;
    }
    if (Log4VRS) NSLog(@"----> S评分:%@ P评分:%@ 评价结果:%@",STRFORMAT(@"%.2f",sScore),STRFORMAT(@"%.2f",pScore),result?@"通过":@"未通过");
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
            if (Log4VRS) NSLog(@"-> %@ 新增: %@ x %ld = %@ 累计:%f 依据:%@",ATType2Str([item.target_p.dataSource integerValue]),STRFORMAT(@"%.2f",rate),(long)item.strong.value,STRFORMAT(@"%.2f",itemStrong),result,Pit2FStr(item.target_p));
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
 *  @result 默认返回true (因为空fo并不指向空S);
 */
+(BOOL) FRS:(AIFoNodeBase*)fo{
    //1. 未发生理性评价-必须为hnglsp节点 (否则F14主解决方案也会失败);
    if ([TOUtils isHNGLSP:fo.pointer]) {
        
        //2. 未发生理性评价-且为空ATSub时,评价不通过;
        NSArray *sPorts = [AINetUtils absPorts_All:fo type:ATSub];
        NSString *spaceHeader = [NSString md5:@""];
        
        //3. 判断sPorts有没有空S (有时返回false,评价不通过);
        for (AIPort *sPort in sPorts) {
            if ([sPort.header isEqualToString:spaceHeader]) {
                return false;
            }
        }
    }
    return true;
}

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

//MARK:===============================================================
//MARK:                     < FPS >
//MARK:===============================================================

/**
 *  MARK:--------------------对TOFoModel进行反思评价--------------------
 *  @version
 *      2021.01.24: 对多时序识别,更准确多元的评价支持 (参考22073-todo2);
 */
+(BOOL) FPS:(TOFoModel*)outModel rtInModel:(AIShortMatchModel*)rtInModel{
    //1. 数据检查
    if (!outModel || !rtInModel) {
        return true;
    }
    
    //2. 对mModel进行评价;
    CGFloat sumScore = 0;
    for (AIMatchFoModel *item in rtInModel.matchFos) {
        CGFloat score = [AIScore score4MV:item.matchFo.cmvNode_p ratio:item.matchFoValue];
        sumScore += score;
    }
    CGFloat rtScore = rtInModel.matchFos.count == 0 ? 0 : sumScore / rtInModel.matchFos.count;
    
    //3. 对demand进行评价 (P-模式下demand为负分);
    DemandModel *demand = [TOUtils getDemandModelWithSubOutModel:outModel];
    CGFloat demandScore = [AIScore score4MV:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
    
    //10. 如果mv同区,只要为负则失败;
    //if ([rtMv_p.algsType isEqualToString:demand.algsType] && [mMv_p.dataSource isEqualToString:cMv_p.dataSource] && mcScore < 0) { return false; }
    
    //4. 如果不同区,对mcScore和curScore返回评价值进行类比 (如宁饿死不吃屎);
    return rtScore > demandScore * 0.5f;
}

//MARK:===============================================================
//MARK:                     < MPS >
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

//同区且同向
+(BOOL) sameScoreOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    if (mv1_p && mv2_p && [mv1_p.identifier isEqualToString:mv2_p.identifier]) {
        CGFloat mScore = [AIScore score4MV:mv1_p ratio:1.0f];
        CGFloat sScore = [AIScore score4MV:mv2_p ratio:1.0f];
        BOOL isSame = ((mScore > 0 && sScore > 0) || (mScore < 0 && sScore < 0));
        return isSame;
    }
    return false;
}
//同向
+(BOOL) sameOfScore1:(CGFloat)score1 score2:(CGFloat)score2{
    BOOL isSame = ((score1 > 0 && score2 > 0) || (score1 < 0 && score2 < 0));
    return isSame;
}

@end
