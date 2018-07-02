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
#import "AIImvAlgs.h"

@implementation AIReactorControl

static AIReactorControl *_instance;
+(AIReactorControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIReactorControl alloc] init];
    }
    return _instance;
}

-(ImvModelBase*) createMindValue:(MVType)type value:(NSInteger)value {
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

-(void) commitIMV:(MVType)type from:(NSInteger)from to:(NSInteger)to {
    //目前smg不支持,在mvType的某些情况下的,肢体反射反应;
    
    [AIImvAlgs commitIMV:type from:from to:to];
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [[AIActionControl shareInstance] commitCustom:type value:value];
}

@end
