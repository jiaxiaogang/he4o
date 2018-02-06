//
//  AIReactorControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIReactorControl.h"
#import "AIActionControl.h"
#import "AIModel.h"

@implementation AIReactorControl

static AIReactorControl *_instance;
+(AIReactorControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIReactorControl alloc] init];
    }
    return _instance;
}

-(ImvModelBase*) createMindValue:(IMVType)type value:(NSInteger)value {
    //1. 根据model判断是否createMindValue();
    //2. 根据model判断是否作Reactor();
    return nil;
}

-(void) createReactor:(AIMoodType)moodType{
    //1. 肢体反射
    //2. createMindValue
    //3. durationManager
}


-(void) commitInput:(id)input{
    [[AIActionControl shareInstance] commitInput:input];
}

-(void) commitInputIMV:(IMVType)type value:(NSInteger)value {
    [[AIActionControl shareInstance] commitInputIMV:type value:value];
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [[AIActionControl shareInstance] commitCustom:type value:value];
}

@end
