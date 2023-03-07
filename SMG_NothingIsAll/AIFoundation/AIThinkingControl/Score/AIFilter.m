//
//  AIFilter.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/25.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AIFilter.h"

@implementation AIFilter

/**
 *  MARK:--------------------概念识别过滤器--------------------
 *  @version
 *      2023.03.06: 概念识别过滤器匹配度为主,强度为辅 (参考28152-方案4-todo4);
 */
+(NSArray*) recognitonAlgFilter:(NSArray*)matchAlgModels {
    return [self filterTwice:matchAlgModels scoreBlock1:^double(AIMatchAlgModel *item) {
        return item.matchValue;
    } rate1:0.2f scoreBlock2:^double(AIMatchAlgModel *item) {
        return item.strongValue;
    } rate2:0.8f];
}

/**
 *  MARK:--------------------时序识别过滤器--------------------
 *  @version
 *      2023.03.06: 时序识别过滤器强度为主,匹配度为辅 (参考28152-方案4-todo5);
 */
+(NSArray*) recognitonFoFilter:(NSArray*)matchModels {
    return [self filterTwice:matchModels scoreBlock1:^double(AIMatchFoModel *item) {
        return item.strongValue;
    } rate1:0.2f scoreBlock2:^double(AIMatchFoModel *item) {
        return item.matchFoValue;
    } rate2:0.8];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------同时符合两项过滤器的前xx% (参考28152-方案3)--------------------
 *  @version
 *      2023.03.06: 过滤前20%改为35% (参考28152-方案3-todo2);
 *      2023.03.07: 减少过滤结果条数(从10到3),避免过滤器久久不生效 (参考28152b-todo1);
 *      2023.03.07: 过滤率改成动态计算,使其条数少时,两个过滤器也都能生效 (参考28152b-todo2);
 */
+(NSArray*) filterTwice:(NSArray*)protoArr scoreBlock1:(double(^)(id item))scoreBlock1 rate1:(CGFloat)rate1 scoreBlock2:(double(^)(id item))scoreBlock2 rate2:(CGFloat)rate2{
    //0. 数据准备;
    if (!ARRISOK(protoArr)) return protoArr;
    //公式说明:
    //1. 要求: 总过滤数20 = 总数30 - 结果数10;
    //2. 主过滤0.8,辅过滤0.2时: 主过滤掉16条,辅过滤掉4条 即可;
    //3. 所以: 主过滤后,剩下14(30-16)条; 辅过滤后剩下10(14-4)条;
    //3. 所以: 主过滤率 = 剩下14 / 总数30;
    //4. 辅过滤率 = 剩下10 / 剩下14;
    NSInteger protoCount = protoArr.count;                          //总数30;
    NSInteger resultNum = 3;                                        //结果返回至少2条;
    resultNum = MAX(protoCount * 0.2f, MIN(resultNum, protoCount)); //结果需要 大于20% 且 小于100%;
    NSInteger filterNum = protoCount - resultNum;                   //总过滤任务 (比如共30条,剩10条,过滤任务就是70%);
    CGFloat totalFilterForce = rate2 / rate1 + 1;                   //总过滤力量份数 (比如主为0.2,辅为0.8,则总力量=5份);
    CGFloat fuFilterNum = filterNum / totalFilterForce;             //辅过滤条数;
    CGFloat zuFilterNum = filterNum - fuFilterNum;                  //主过滤条数;
    CGFloat zuRate = (protoCount - zuFilterNum) / protoCount;       //主过滤率;
    CGFloat fuRate = resultNum / (protoCount - zuFilterNum);        //辅过滤率;
    NSLog(@"过滤器: 总条:%ld 主:%.2f 辅:%.2f 结果:%ld",protoCount,zuRate,fuRate,resultNum);
    
    //1. 分别按1和2过滤前35%;
    NSArray *filter1 = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:scoreBlock1], 0, MAX(10, protoArr.count * zuRate));
    NSArray *filter2 = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:scoreBlock2], 0, MAX(10, protoArr.count * fuRate));
    
    //2. 过滤出同时符合二项的,并返回 (参考28152-方案3-todo3);
    NSArray *filterTwice = [SMGUtils filterArr:protoArr checkValid:^BOOL(id item) {
        return [filter1 containsObject:item] && [filter2 containsObject:item];
    }];
    return filterTwice;
}

@end
