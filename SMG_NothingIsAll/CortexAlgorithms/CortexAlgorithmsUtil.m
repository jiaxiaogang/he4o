//
//  CortexAlgorithmsUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/3/13.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "CortexAlgorithmsUtil.h"

@implementation CortexAlgorithmsUtil

/**
 *  MARK:--------------------返回首尾循环码的最大值--------------------
 *  @desc 值说明 (参考28174-todo2):
 *          1. 首尾相连的稀疏码最小值一般都为0;
 *          2. 因为最大值等于最小值,所以此处将最大值返回,以方便计算差值;
 *  @param itemIndex 每种组码可能有多个索引，而这几个索引有些是循环，有些不是，要在这里判断下。
 *  @version
 *      2023.03.14: 飞行方向也是首尾循环码 (参考28174-todo2-另外);
 *  @result 首尾循环的返回最大值,如果不循环的值则返回0;
 */
+(double) maxOfLoopValue:(NSString*)at ds:(NSString*)ds itemIndex:(NSInteger)itemIndex {
    //1. 视觉方向有360个值;
    if ([@"AIVisionAlgs" isEqualToString:at] && [@"direction" isEqualToString:ds]) {
        return 360;
    } else if ([@"FLY_RDS" isEqualToString:at]) {
        return 1;
    } else if ([@"AIVisionAlgsV2" isEqualToString:at]) {
        BOOL dsIsLoop = [@"hColors" isEqualToString:ds];//HSB色值中的色相，是循环值。
        if (itemIndex == GVIndexTypeOfDirection) {
            return 1;//方向是循环
        } else if (itemIndex == GVIndexTypeOfDiffNum) {
            return 0;//差值不是循环
        } else if (itemIndex == GVIndexTypeOfPinJunNum) {
            return dsIsLoop;
        } else {
            return dsIsLoop;
        }
    } else if ([@"hColors_direction" isEqualToString:at]) {
        return 1;
    } else if ([@"hColors_diff" isEqualToString:at]) {
        return 1;
    } else if ([@"hColors_jun" isEqualToString:at]) {
        return 1;
    } else if ([@"sColors_direction" isEqualToString:at]) {
        return 1;
    } else if ([@"bColors_direction" isEqualToString:at]) {
        return 1;
    }
    return 0;
}

//稀疏码的相近度（返回两个值的差值）
+(double) nearDeltaOfValue:(CGFloat)protoNum assNum:(CGFloat)assNum max:(CGFloat)max {
    //1. 循环时: 计算nearV相近度算法 (参考28174-todo4);
    double nearDelta = fabs(assNum - protoNum);
    if (max > 0 && nearDelta > (max / 2)) nearDelta = max - nearDelta;
    return nearDelta;
}


/**
 *  MARK:--------------------取子粒度层9格--------------------
 *  @desc 即更细粒度下层。
 *  @参数说明：根据当前层的curLevel,curRow,curColumn来取。
 *  @splitDic 要求下一层的splitDic已经初始化，存在这个字典里（这样才能取到值）。
 */
+(NSArray*) getSub9DotFromSplitDic:(NSInteger)curLevel curRow:(NSInteger)curRow curColumn:(NSInteger)curColumn splitDic:(NSDictionary*)splitDic {
    //1. 别的粗粒度，都从result的细一级粒度取值（把lastLevel取到的9个值取平均值=做为当前Level的HSB值）。
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 找到下层，的9个row,column格（顺序为从行内左到右，多行从上到下，依次收集9格）。
    NSInteger nextLevel = curLevel + 1;
    for (NSInteger j = 0; j < 3; j++) {
        NSInteger nextColumn = curColumn * 3 + j;
        for (NSInteger i = 0; i < 3; i++) {
            NSInteger nextRow = curRow * 3 + i;
            
            //3. 把这九个格的色值分别取出来，求平均值收集。
            NSString *nextKey = STRFORMAT(@"%ld_%ld_%ld",nextLevel,nextRow,nextColumn);
            id nextItemColor = [splitDic objectForKey:nextKey];
            [result addObject:[MapModel newWithV1:nextItemColor v2:@(i) v3:@(j)]];//其中ij表示子点它自身的xy位置，范围为0-2，共九格。
        }
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < V2新版本方法组 >
//MARK:===============================================================
+(CGFloat) deltaOfCustomV1:(double)v1 v2:(double)v2 max:(CGFloat)max min:(CGFloat)min loop:(BOOL)loop {
    //1. 数据准备;
    CGFloat span = max - min;
    if (span == 0) return 1;
    CGFloat delta = fabs(v1 - v2);
    
    //2. 如果是循环V时,正反取小（比如Delta=0.8，计算后变成0.2）;
    if (loop && delta > (span / 2)) {
        delta = max - delta;
    }
    return delta;
}

+(CGFloat) matchValueOfCustomV1:(double)v1 v2:(double)v2 max:(CGFloat)max min:(CGFloat)min loop:(BOOL)loop {
    //1. 数据准备;
    CGFloat span = max - min;
    if (span == 0) return 1;
    CGFloat delta = [self deltaOfCustomV1:v1 v2:v2 max:max min:min loop:loop];
    
    //3. 循环时: 计算出nearV相近度 (参考28174-todo2);
    if (loop) {
        return 1 - delta / (span / 2);
    }
    
    //4. 线性时: 计算出nearV相近度 (参考25082-公式1);
    return 1 - delta / span;
}

+(BOOL) dsIsLoop:(NSString*)ds {
    return [@"hColors" isEqualToString:ds] || //HSB色值中的色相，是循环值;
    [@"direction" isEqual:ds] ||//方向是循环值。
    [@"hColors_diff" isEqual:ds];
}

@end
