//
//  NSString+Extension.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

+(NSString*) md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString*) double2Str_NoDotZero:(double)value{
    //1. 数据检查
    NSString *floatStr = STRFORMAT(@"%f",value);
    NSRange dotRange = [floatStr rangeOfString:@"."];
    if (dotRange.location <= 0) return floatStr;
    
    //2. 取lastDotOrZeroIndex
    NSInteger dotOrZeroIndex = floatStr.length;
    for (NSInteger i = floatStr.length - 1; i >= 0; i--) {
        NSString *iChar = [floatStr substringWithRange:NSMakeRange(i, 1)];
        if ([@"0" isEqualToString:iChar]) {
            dotOrZeroIndex = i;
        }else if([@"." isEqualToString:iChar]){
            dotOrZeroIndex = i;
            break;
        }else{
            break;
        }
    }
    return [floatStr substringToIndex:dotOrZeroIndex];
}

/**
 *  MARK:--------------------找字符串在字符串出现次数--------------------
 *  @demo NSLog(@"次数:%d",[NSString countOfSubStr:@"abcd=1" fromStr:@"abcdabceabdfaddd"]);
 *        NSLog(@"次数:%d",[NSString countOfSubStr:@"abc=2" fromStr:@"abcdabceabdfaddd"]);
 *        NSLog(@"次数:%d",[NSString countOfSubStr:@"ab=3" fromStr:@"abcdabceabdfaddd"]);
 *        NSLog(@"次数:%d",[NSString countOfSubStr:@"a=4" fromStr:@"abcdabceabdfaddd"]);
 */
+(int) countOfSubStr:(NSString*)subStr fromStr:(NSString*)fromStr {
    subStr = STRTOOK(subStr);
    fromStr = STRTOOK(fromStr);
    int resultCount = 0;
    do {
        NSRange range = [fromStr rangeOfString:subStr];
        
        //未发现,退出循环;
        if (range.location == NSNotFound) break;
        
        //发现,则计数+1,并截掉找过的部分;
        fromStr = [fromStr substringFromIndex:range.location + range.length];
        resultCount++;
    } while (true);
    return resultCount;
}

@end
