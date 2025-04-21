//
//  AIGroupValueNextVModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIGroupValueNextVModel.h"

@implementation AIGroupValueNextVModel

-(NSArray*) getValidValue_ps:(NSInteger)x y:(NSInteger)y {
    return [self.everyXYValidValue_ps objectForKey:STRFORMAT(@"%ld_%ld",x,y)];
}

@end
