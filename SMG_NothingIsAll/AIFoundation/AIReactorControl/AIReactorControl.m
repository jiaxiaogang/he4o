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
#import "OutputModel.h"

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

+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to {
    //目前smg不支持,在mvType的某些情况下的,肢体反射反应;
    [AIImvAlgs commitIMV:type from:from to:to];
}

+(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    [AICustomAlgs commitCustom:type value:value];
}

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect{
    [AIVisionAlgs commitView:selfView targetView:targetView rect:rect];
}

+(void) commitReactor:(NSString*)rds{
    [self commitReactor:rds datas:@[@(1)]];
}
+(void) commitReactor:(NSString*)rds datas:(NSArray*)datas{
    //1. 转为outModel
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSNumber *data in ARRTOOK(datas)) {
        OutputModel *model = [[OutputModel alloc] init];
        model.rds = STRTOOK(rds);
        model.data = NUMTOOK(data);
        [models addObject:model];
    }
    
    //2. 传递到output执行
    if (ARRISOK(models)) {
        [Output output_Reactor:models];
    }
}

@end
