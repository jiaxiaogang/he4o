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
 *  @version
 *      2023.03.14: 飞行方向也是首尾循环码 (参考28174-todo2-另外);
 *  @result 首尾循环的返回最大值,如果不循环的值则返回0;
 */
+(double) maxOfLoopValue:(NSString*)at ds:(NSString*)ds {
    //1. 视觉方向有360个值;
    if ([@"AIVisionAlgs" isEqualToString:at] && [@"direction" isEqualToString:ds]) {
        return 360;
    } else if ([@"FLY_RDS" isEqualToString:at]) {
        return 1;
    } else if ([@"AIVisionAlgsV2" isEqualToString:at] && [@"hColors" isEqualToString:ds]) {
        return 1;//HSB色值中的色相，是循环值。
    }
    return 0;
}


/**
 *  MARK:--------------------取子粒度层9格--------------------
 *  @desc 即更细粒度下层。
 *  @参数说明：根据当前层的curLevel,curRow,curColumn来取。
 *  @splitDic 要求下一层的splitDic已经初始化，存在这个字典里（这样才能取到值）。
 */

/**
 *  MARK:--------------------从更细粒度一层（下一层）取当前层curRow,curColumn的平均色值--------------------
 *  @nextLevelSplitDic 要求下一层的splitDic已经初始化，存在这个字典里（这样才能取到值）。
 */
+(NSDictionary*) getSub9DotFromSplitDic:(NSInteger)curLevel curRow:(NSInteger)curRow curColumn:(NSInteger)curColumn splitDic:(NSDictionary*)splitDic {
    //1. 别的粗粒度，都从result的细一级粒度取值（把lastLevel取到的9个值取平均值=做为当前Level的HSB值）。
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 找到下层，的9个row,column格。
    NSInteger nextLevel = curLevel + 1;
    for (NSInteger i = 0; i < 3; i++) {
        NSInteger nextRow = curRow * 3 + i;
        for (NSInteger j = 0; j < 3; j++) {
            NSInteger nextColumn = curColumn * 3 + j;
            
            //3. 把这九个格的色值分别取出来，求平均值收集。
            NSString *nextKey = STRFORMAT(@"%ld_%ld_%ld",nextLevel,nextRow,nextColumn);
            id nextItemColor = [splitDic objectForKey:nextKey];
            [result setObject:nextItemColor forKey:nextKey];
        }
    }
    return result;
}

@end
