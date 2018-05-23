//
//  XGRedisUtil.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "XGRedisUtil.h"

@implementation XGRedisUtil

/**
 *  MARK:--------------------比较strA是否比strB大(ascii)--------------------
 */
+(NSComparisonResult) compareStrA:(NSString*)strA strB:(NSString*)strB{
    //1. 数据检查 & 准备
    strA = STRTOOK(strA);
    strB = STRTOOK(strB);
    NSInteger aLength = strA.length;
    NSInteger bLength = strB.length;
    
    //2. 比较大小
    for (NSInteger i = 0; i < MIN(aLength, bLength); i++) {
        unichar cA = [strA characterAtIndex:i];
        unichar cB = [strB characterAtIndex:i];
        if (cA > cB) {
            return NSOrderedAscending;
        }else if(cA < cB){
            return NSOrderedDescending;
        }
    }
    
    //3. 前面都一样
    return aLength > bLength ? NSOrderedAscending : aLength < bLength ? NSOrderedDescending : NSOrderedSame;
}

/**
 *  MARK:--------------------二分查找--------------------
 *  success:找到则返回相应index
 *  failure:失败则返回可排到的index
 *  要求:arr指向的值是正序的;(即数组下标越大,值越大)
 */
+(void) searchIndexWithCompare:(NSComparisonResult (^)(NSInteger checkIndex))compare startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex success:(void(^)(NSInteger index))success failure:(void(^)(NSInteger index))failure {
    if (compare) {
        //1. index越界检查
        startIndex = MAX(0, startIndex);
        
        //2. 相邻或相等时,直接对比返回
        if (labs(startIndex - endIndex) <= 1) {
            //3. 与start对比
            NSComparisonResult result = compare(startIndex);
            if (result == NSOrderedDescending) {      //比小的小
                if (failure) failure(startIndex);
            }else if (result == NSOrderedSame){       //相等
                if (success) success(startIndex);
            }else {                                   //比小的大
                if(startIndex == endIndex) {
                    if (failure) failure(startIndex + 1);
                }else{
                    //4. 与end对比
                    NSComparisonResult result = compare(endIndex);
                    if (result == NSOrderedAscending) { //比大的大
                        if (failure) failure(endIndex + 1);
                    }else if (result == NSOrderedSame){ //相等
                        if (success) success(endIndex);
                    }else {                             //比大的小
                        if (failure) failure(endIndex);
                    }
                }
            }
        }else{
            //5. 与mid对比
            NSInteger midIndex = (startIndex + endIndex) / 2;
            NSComparisonResult result = compare(midIndex);
            if (result == NSOrderedAscending) { //比中心大(检查mid到endIndex)
                [self searchIndexWithCompare:compare startIndex:midIndex endIndex:endIndex success:success failure:failure];
            }else if (result == NSOrderedSame){ //相等
                if (success) success(midIndex);
            }else {                             //比中心小(检查startIndex到mid)
                [self searchIndexWithCompare:compare startIndex:startIndex endIndex:midIndex success:success failure:failure];
            }
        }
    }else{
        if (failure) failure(0);
    }
}

@end
