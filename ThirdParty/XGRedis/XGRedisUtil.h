//
//  XGRedisUtil.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGRedisUtil : NSObject

/**
 *  MARK:--------------------比较strA是否比strB大(ascii)--------------------
 */
+(NSComparisonResult) compareStrA:(NSString*)strA strB:(NSString*)strB;



/**
 *  MARK:--------------------二分查找--------------------
 *  success:找到则返回相应index
 *  failure:失败则返回可排到的index
 *  要求:arr指向的值是正序的;(即数组下标越大,值越大)
 */
+(void) searchIndexWithCompare:(NSComparisonResult (^)(NSInteger checkIndex))compare startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex success:(void(^)(NSInteger index))success failure:(void(^)(NSInteger index))failure;


@end
