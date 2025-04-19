//
//  InputDotModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "InputGroupValueModel.h"

@implementation InputGroupValueModel

+(id) new:(NSArray*)subDots groupValue:(AIKVPointer*)groupValue_p rect:(CGRect)rect {
    InputGroupValueModel *result = [[InputGroupValueModel alloc] init];
    result.subDots = subDots;
    result.rect = rect;
    result.groupValue_p = groupValue_p;
    if (rect.size.width == 0 || rect.size.height == 0) {
        ELog(@"查下这里rect尺寸为0复现时，这个尺寸为0哪来的1");
    }
    return result;
}

@end
