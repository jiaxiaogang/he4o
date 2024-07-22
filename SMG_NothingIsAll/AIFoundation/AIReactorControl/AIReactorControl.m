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
#import "AIVisionAlgs.h"
#import "AICustomAlgs.h"

@implementation AIReactorControl

+(ImvAlgsModelBase*) createMindValue:(MVType)type value:(NSInteger)value {
    //1. 根据model判断是否createMindValue();
    //2. 根据model判断是否作Reactor();
    return nil;
}

+(void) createReactor:(AIMoodType)moodType{
    //1. 肢体反射
    //2. createMindValue
    //3. durationManager
}


+(void) commitInput:(id)input{
    if (ISOK(input, [NSString class])) {
        [AIStringAlgs commitInput:input];
    }
}

+(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AICustomAlgs commitCustom:type value:value];
}

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect{
    [AIVisionAlgs commitView:selfView targetView:targetView rect:rect];
}

+(void) commitReactor:(NSString*)identify{
    [self commitReactor:identify datas:@[@(1)]];
}
+(void) commitReactor:(NSString*)identify datas:(NSArray*)datas{
    [Output output_FromReactor:identify datas:datas];
}

@end
