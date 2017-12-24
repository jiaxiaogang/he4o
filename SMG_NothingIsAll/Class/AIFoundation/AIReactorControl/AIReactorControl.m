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
#import "AIInputMindValue.h"
#import "AIIMVCharge.h"
#import "AIIMVHunger.h"

@implementation AIReactorControl

static AIReactorControl *_instance;
+(AIReactorControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIReactorControl alloc] init];
    }
    return _instance;
}

-(AIInputMindValue*) createMindValue:(IMVType)type value:(NSInteger)value {
    if (type == IMVType_Charge) {
        AIIMVCharge *model = [[AIIMVCharge alloc] init];
        model.state = HungerState_Charging;
        model.value = value;
        return model;
    }else if(type == IMVType_Hunger) {
        AIIMVHunger *model = [[AIIMVHunger alloc] init];
        model.level = value;
        model.value = value;
        return model;
    }else{
        
    }
    return nil;
}

-(void) createReactor:(AIMoodType)moodType{
    //1. 肢体反射
    //2. createMindValue
    //3. durationManager
}


-(void) commitInput:(id)input{
    [self createReactor:AIMoodType_Anxious];
    [[AIActionControl shareInstance] commitInput:input];
}

-(void) commitInputIMV:(IMVType)type value:(NSInteger)value {
    AIInputMindValue *model = [self createMindValue:type value:value];
    [[AIActionControl shareInstance] commitInput:model];
}

-(void) commitModel:(AIModel*)model{
    //1. 根据model判断是否createMindValue();
    //2. 根据model判断是否作Reactor();
    [[AIActionControl shareInstance] insertModel:model];
}

@end
