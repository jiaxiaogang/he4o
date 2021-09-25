//
//  AITest.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/9/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AITest.h"

@implementation AITest

+(void) test4:(AIKVPointer*)pointer at:(NSString*)at isOut:(BOOL)isOut{
    if (PitIsValue(pointer)) {
        if ([at isEqualToString:FLY_RDS] && !isOut) {
            NSLog(@"自检4. 行为飞稀疏码的isOut为false的问题");
        }
    }
}

@end
