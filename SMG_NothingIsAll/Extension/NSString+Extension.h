//
//  NSString+Extension.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

/**
 *  md5加密的字符串
 */
+(NSString*) md5:(NSString *)str;

/**
 *  MARK:-------------------- 截掉浮点数字符串后面的多余0--------------------
 */
+(NSString*) double2Str_NoDotZero:(double)value;

/**
 *  MARK:--------------------找字符串在字符串出现次数--------------------
 */
+(int) countOfSubStr:(NSString*)subStr fromStr:(NSString*)fromStr;

@end
