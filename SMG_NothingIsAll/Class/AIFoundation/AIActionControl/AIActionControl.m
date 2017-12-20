//
//  AIActionControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIActionControl.h"
#import "AINet.h"
#import "AIStringAlgs.h"
#import "PINCache.h"

@implementation AIActionControl

static AIActionControl *_instance;
+(AIActionControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIActionControl alloc] init];
    }
    return _instance;
}

-(void) commitInput:(id)input{
    if (input) {
        if (ISOK(input, [NSString class])) {
            //1. 调用算法处理
            [AIStringAlgs commitInput:input];
        }
    }
}

-(void) commitModel:(AIModel*)model{
    [theNet commitModel:model];
}

@end
