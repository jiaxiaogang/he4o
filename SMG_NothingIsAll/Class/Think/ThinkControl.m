//
//  ThinkControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkControl.h"
#import "ThinkHeader.h"

@implementation ThinkControl

-(Understand *)understand{
    if (!_understand) {
        _understand = [[Understand alloc] init];
    }
    return _understand;
}


-(Decision *)decision{
    if (_decision == nil) {
        _decision = [[Decision alloc] init];
    }
    return _decision;
}

@end
