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

@implementation AIScore

/**
 *  MARK:--------------------VRS评分--------------------
 *  @desc 值域求和V2: 束波求和简化版,采取线函数来替代找交点 (参考21212 & 21213);
 *  @param sPorts : 传入Alg.ATSub的端口组;
 *  @param maskIdentifier : 此次要获取值域求和的稀疏码标识;
 *  @result <-2 时评价为否 (参考22025-分析2);
 *  @todo
 *      2021.01.01: 在排序后对同值的元素抵消(s3+p5=p2) (先不实现,因为同值此时交点即会直接取到值,在评价时,似乎这样并没有什么问题);
 *  @version
 *      2021.01.02: 解决sort未被接收,导致排序不生效的BUG;
 *      2021.01.02: 支持maskIdentifier,因为原来把alg当成value来取值,导致生成sumModels和评价完全错误 (参考21216);
 *      2021.01.10: v2迭代,由偶发性导致的评价BUG引出迭代 (参考n22p2);
 *      2021.01.10: v2迭代,之直线范围累计法 (参考22025-方案5);
 */
+(BOOL) VRS:(AIKVPointer*)value_p sPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts maskIdentifier:(NSString*)maskIdentifier{
    double sScore = [self score4Value:value_p spPorts:sPorts maskIdentifier:maskIdentifier];
    double pScore = [self score4Value:value_p spPorts:pPorts maskIdentifier:maskIdentifier];
    return pScore - sScore < -2;
}
+(double) score4Value:(AIKVPointer*)value_p spPorts:(NSArray*)spPorts maskIdentifier:(NSString*)maskIdentifier{
    //1. 数据准备;
    double result = 0;
    spPorts = ARRTOOK([SMGUtils filterAlgPorts:spPorts valueIdentifier:maskIdentifier]);
    if (!ARRISOK(spPorts)) return result;
    double value = [NUMTOOK([AINetIndex getData:value_p]) doubleValue];
    
    //2. 从小到大排序;
    NSArray *sortPorts = [spPorts sortedArrayUsingComparator:^NSComparisonResult(AIPort *p1, AIPort *p2) {
        double v1 = [AINetService getValueDataFromAlg:p1.target_p valueIdentifier:maskIdentifier];
        double v2 = [AINetService getValueDataFromAlg:p2.target_p valueIdentifier:maskIdentifier];
        return [SMGUtils compareFloatA:v2 floatB:v1];
    }];
    
    //3. 找出max-min (影响范围为1/3,一边一半);
    AIPort *minPort = ARR_INDEX(sortPorts, 0);
    AIPort *maxPort = ARR_INDEX_REVERSE(sortPorts, 0);
    double minValue = [AINetService getValueDataFromAlg:minPort.target_p valueIdentifier:maskIdentifier];
    double maxValue = [AINetService getValueDataFromAlg:maxPort.target_p valueIdentifier:maskIdentifier];
    double scope = (maxValue - minValue) / 3.0f / 2.0f;
    
    //4. 累计
    for (AIPort *item in sortPorts) {
        double itemValue = [AINetService getValueDataFromAlg:item.target_p valueIdentifier:maskIdentifier];
        double distance = fabs(itemValue - value);
        if (distance <= scope) {
            double rate = scope > 0 ? (scope - distance) / scope : 1.0f;
            double itemStrong = rate * item.strong.value;
            result += itemStrong;
        }
    }
    return result;
}

@end
