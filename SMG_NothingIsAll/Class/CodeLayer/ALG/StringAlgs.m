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

+(AIValue*) length:(NSString*)str {
    str = STRTOOK(str);
    return [AIValue newWithIntegerValue:str.length];
}


@end
