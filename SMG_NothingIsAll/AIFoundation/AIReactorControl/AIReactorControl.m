//
//  AIReactorControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIReactorControl.h"
#import "AIStringAlgs.h"
#import "AIImvAlgs.h"
#import "ImvAlgsModelBase.h"
#import "AIVisionAlgs.h"
#import "AICustomAlgs.h"
#import "Output.h"

@implementation AIReactorControl

static AIReactorControl *_instance;
+(AIReactorControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIReactorControl alloc] init];
    }
    return _instance;
}

-(ImvAlgsModelBase*) createMindValue:(MVType)type value:(NSInteger)value {
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
    if (ISOK(input, [NSString class])) {
        [AIStringAlgs commitInput:input];
    }
}

-(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to {
    //目前smg不支持,在mvType的某些情况下的,肢体反射反应;
    [AIImvAlgs commitIMV:type from:from to:to];
}

-(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AICustomAlgs commitCustom:type value:value];
}

-(void) commitView:(UIView*)selfView targetView:(UIView*)targetView{
    [AIVisionAlgs commitView:selfView targetView:targetView];
}

/**
 *  MARK:--------------------提交反射反应--------------------
 *  1. 由外围神经提交一个反射信号;
 *  2. ReactorControl在收到信号后,响应反射;
 *  3. 并把反射执行的outLog构建到网络中;
 *
 *  目的: 是让he学会自主使用某外围功能;
 *  备注: 目前支持1个nsnumber参数; (也可以暂不支持参数)
 *
 *  @params rds   : 反射标识
 *
 */
-(void) commitReactor:(NSString*)rds{
    //1. 传递到output执行
    NSNumber *paramNum = @(1);
    [Output output_Reactor:rds paramNum:paramNum];
}

@end
