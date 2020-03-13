//
//  HeLogUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/14.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLogUtil.h"

@implementation HeLogUtil

/**
 *  MARK:--------------------filter--------------------
 */
+(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT checkDatas:(NSArray*)checkDatas{
    //1. 转换startT和endT的时间戳;
    checkDatas = ARRTOOK(checkDatas);
    if (!STRISOK(startT) || !STRISOK(endT)) {
        //ELog(@"输入时间格式错误!!! (%@,%@)",startT,endT);
        return checkDatas;
    }
    NSDate *startDate = [SMGUtils dateFromTimeStr_yyyyMMddHHmmssSSS:startT];
    NSDate *endDate = [SMGUtils dateFromTimeStr_yyyyMMddHHmmssSSS:endT];
    if (!startDate || !endDate) {
        ELog(@"时间转换错误!!! (%@,%@)",startT,endT);
        return checkDatas;
    }
    long long startTime = [startDate timeIntervalSince1970] * 1000.0f;
    long long endTime = [endDate timeIntervalSince1970] * 1000.0f;
    
    //2. 找起始index
    NSInteger startIndex = checkDatas.count;
    NSInteger endIndex = -1;
    for (NSDictionary *item in checkDatas) {
        long long itemTime = [NUMTOOK([item objectForKey:kTime]) longLongValue];
        if (itemTime >= startTime && startIndex == checkDatas.count) {
            startIndex = [checkDatas indexOfObject:item];
        }
        if (itemTime == endTime) {
            endIndex = [checkDatas indexOfObject:item];
        }else if(itemTime < endTime){
            endIndex = [checkDatas indexOfObject:item] - 1;
        }
    }
    
    //3. 截取
    NSInteger length = endIndex - startIndex + 1;
    return ARR_SUB(checkDatas, startIndex,length);
}

+(NSArray*) filterByKeyword:(NSString*)keyword checkDatas:(NSArray*)checkDatas{
    //1. 数据准备
    checkDatas = ARRTOOK(checkDatas);
    if (!STRISOK(keyword)) {
        return checkDatas;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *sep = @" ";
    NSArray *kws = STRTOARR(keyword, sep);
    
    //2. 筛选
    for (NSDictionary *item in checkDatas) {
        NSString *log = [item objectForKey:kLog];
        
        //3. 判断包含所有关键字:kws
        BOOL contains = true;
        for (NSString *kw in kws) {
            if (![log containsString:kw]) {
                contains = false;
                break;
            }
        }
        if (contains) {
            [result addObject:item];
        }
    }
    return result;
}

@end
