//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"
#import "AIThinkingControl.h"

@implementation Output

+(NSString*) getReactorMethodName{
    return NSStringFromSelector(@selector(output_Reactor:paramNum:));
}

+(void) output_Face:(AIMoodType)type{
    const char *chars = nil;
    if (type == AIMoodType_Anxious) {
        chars = [@"T_T" UTF8String];
    }else if(type == AIMoodType_Satisfy){
        chars = [@"^_^" UTF8String];
    }
    if (chars) {
        [self output_Reactor:TEXT_RDS paramNum:@(chars[0])];
        [self output_Reactor:TEXT_RDS paramNum:@(chars[1])];
        [self output_Reactor:TEXT_RDS paramNum:@(chars[2])];
    }
}

+(void) output_Reactor:(NSString*)rds paramNum:(NSNumber*)paramNum{
    if (paramNum) {
        //1. 将输出入网;(TODO:将入网改到tc处,dataOut处应该自行入网)
        [[AIThinkingControl shareInstance] commitOutputLog:NSStringFromClass(self) dataSource:STRTOOK(rds) outputObj:paramNum];
        
        //2. 广播执行;
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":STRTOOK(rds),@"paramNum":NUMTOOK(paramNum)}];
    }
}

@end
