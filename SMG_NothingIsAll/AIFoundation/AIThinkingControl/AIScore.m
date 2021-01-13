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
 */
+(BOOL) VRS:(AIKVPointer*)value_p sPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts {
    if (Log4VRS) NSLog(@"============== VRS ==============%@",Pit2FStr(value_p));
    double sScore = [self score4Value:value_p spPorts:sPorts];
    if (Log4VRS) NSLog(@"----> S评分: %@",STRFORMAT(@"%.2f",sScore));
    double pScore = [self score4Value:value_p spPorts:pPorts];
    if (Log4VRS) NSLog(@"----> P评分: %@",STRFORMAT(@"%.2f",pScore));
    return sScore - pScore < 2;
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
            if (Log4VRS) NSLog(@"-> 新增: %@ x %ld = %@ 累计:%f 依据:%@",STRFORMAT(@"%.2f",rate),(long)item.strong.value,STRFORMAT(@"%.2f",itemStrong),result,Pit2FStr(item.target_p));
        }
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < FRS >
//MARK:===============================================================

/**
 *  MARK:--------------------未发生理性评价 (空S)--------------------
 *  @todo
 *      2020.12.28: 现在代码看起来S判空有问题,应该取出S并判断count是否为0;
 *  @result 默认返回true (因为空fo并不指向空S);
 */
+(BOOL) FRS:(AIFoNodeBase*)fo{
    //1. 未发生理性评价-必须为hngl节点 (否则F14主解决方案也会失败);
    if ([TOUtils isHNGL:fo.pointer]) {
        
        //2. 未发生理性评价-且为空ATSub时,评价不通过;
        NSArray *sPorts = [AINetUtils absPorts_All:fo type:ATSub];
        for (AIPort *item in sPorts) {
            NSLog(@"    sPort: %@",Pit2FStr(item.target_p));
        }
        BOOL reasonScore = !ARRISOK(sPorts);
        return reasonScore;
    }
    return true;
}

//MARK:===============================================================
//MARK:                     < FPS >
//MARK:===============================================================

/**
 *  MARK:--------------------对TOFoModel进行反思评价--------------------
 */
+(BOOL) FPS:(TOFoModel*)outModel rtBlock:(AIShortMatchModel*(^)(void))rtBlock{
    if (!outModel || !rtBlock) {
        return true;
    }
    //6. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
    AIShortMatchModel *rtModel = rtBlock();
    
    //7. MC反思: 对mModel进行评价;
    AIKVPointer *rtMv_p = rtModel.matchFo.cmvNode_p;
    CGFloat rtScore = [AIScore score4MV:rtMv_p ratio:rtModel.matchFoValue];
    
    //8. 对原fo进行评价
    DemandModel *demand = [TOUtils getDemandModelWithSubOutModel:outModel];
    CGFloat curScore = [AIScore score4MV:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
    
    //10. 如果mv同区,只要为负则失败;
    //if ([rtMv_p.algsType isEqualToString:demand.algsType] && [mMv_p.dataSource isEqualToString:cMv_p.dataSource] && mcScore < 0) { return false; }
    
    //11. 如果不同区,对mcScore和curScore返回评价值进行类比 (如宁饿死不吃屎);
    return rtScore > curScore * 0.5f;
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

@end
