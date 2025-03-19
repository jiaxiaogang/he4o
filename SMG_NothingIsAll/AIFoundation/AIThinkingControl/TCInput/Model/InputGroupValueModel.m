//
//  InputDotModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "InputGroupValueModel.h"

@implementation InputGroupValueModel

+(id) new:(NSArray*)subDot_ps level:(NSInteger)level x:(NSInteger)x y:(NSInteger)y {
    InputGroupValueModel *result = [[InputGroupValueModel alloc] init];
    result.subDot_ps = subDot_ps;
    result.level = level;
    result.x = x;
    result.y = y;
    return result;
}

@end
