//
//  AIActionControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIActionControl.h"
#import "AINet.h"
#import "StringAlgs.h"

@implementation AIActionControl

static AIActionControl *_instance;
+(AIActionControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIActionControl alloc] init];
    }
    return _instance;
}

-(void) commitModel:(AIModel*)model{
    [theNet commitModel:model];
}

-(void) commitInput:(id)input{
    if (input) {
        if (ISOK(input, [NSString class])) {
            //2. 调用反射算法处理并返回值给临时神经网络缓存区;
            NSUInteger length = [StringAlgs length:input];
        }
    }
}

@end
