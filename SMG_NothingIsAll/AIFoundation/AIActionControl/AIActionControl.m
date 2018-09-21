//
//  AIActionControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIActionControl.h"
#import "AIStringAlgs.h"
#import "PINCache.h"
#import "AICustomAlgs.h"
#import "ImvAlgsModelBase.h"
#import "AINet.h"

@implementation AIActionControl

static AIActionControl *_instance;
+(AIActionControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIActionControl alloc] init];
    }
    return _instance;
}

-(void) commitInput:(id)input{
    if (ISOK(input, [NSString class])) {
        [AIStringAlgs commitInput:input];
    }
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AICustomAlgs commitCustom:type value:value];
}

@end
