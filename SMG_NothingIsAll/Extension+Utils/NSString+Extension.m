//
//  NSString+Extension.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

-(NSMutableArray*) rangeArrOfString:(NSString*)str{
    NSMutableArray *valueArr = nil;
    if (!STRISOK(str)) {
        return valueArr;
    }
    
    NSInteger curIndex = 0;
    while (curIndex < self.length) {
        NSString *checkStr = [self substringFromIndex:curIndex];
        if (!STRISOK(checkStr)) {
            return valueArr;
        }
        NSRange range = [checkStr rangeOfString:str];
        if (range.location != NSNotFound) {
            if (valueArr == nil) {
                valueArr = [[NSMutableArray alloc] init];
            }
            [valueArr addObject:SMGRangeMake(range.location, range.length)];
            curIndex += range.location + range.length;
        }else{
            break;//找完了,退出循环;
        }
    }
    return valueArr;
}


@end
