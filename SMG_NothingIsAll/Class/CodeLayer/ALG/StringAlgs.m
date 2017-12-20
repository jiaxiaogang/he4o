//
//  StringAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "StringAlgs.h"
#import "AIValue.h"

@implementation StringAlgs

+(NSUInteger) length:(NSString*)str {
    if (STRISOK(str)) {
        return str.length;
    }
    return 0;
}

@end
