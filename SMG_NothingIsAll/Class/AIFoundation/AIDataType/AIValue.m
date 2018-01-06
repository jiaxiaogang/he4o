//
//  AIValue.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/10/18.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIValue.h"

@implementation AIValue


+(AIValue*) newWithDoubleValue:(double)doubleValue {
    AIValue *val = [[AIValue alloc] init];
    val.doubleValue = doubleValue;
    return val;
}

+(AIValue*) newWithIntegerValue:(NSInteger)integerValue {
    AIValue *val = [[AIValue alloc] init];
    val.doubleValue = integerValue;
    return val;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.doubleValue = [coder decodeDoubleForKey:@"doubleValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeDouble:self.doubleValue forKey:@"doubleValue"];
}

@end
