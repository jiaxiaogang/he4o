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

static Output *_instance;
+(Output*) sharedInstance{
    if (_instance == nil) {
        _instance = [[Output alloc] init];
    }
    return _instance;
}

+(void) output_Text:(NSNumber*)charNum{
    if (charNum) {
        char c = [charNum charValue];
        Output *op = [Output sharedInstance];
        if (op.delegate && [op.delegate respondsToSelector:@selector(output_Text:)]) {
            [op.delegate output_Text:c];
        }
        
        //2. 将输出入网;(TODO:将入网改到tc处,dataOut处应该自行入网)
        [[AIThinkingControl shareInstance] commitOutputLog:NSStringFromClass(self) dataSource:NSStringFromSelector(@selector(output_Text:)) outputObj:charNum];
    }
}

+(void) output_Face:(AIMoodType)type{
    const char *chars = nil;
    if (type == AIMoodType_Anxious) {
        chars = [@"T_T" UTF8String];
    }else if(type == AIMoodType_Satisfy){
        chars = [@"^_^" UTF8String];
    }
    if (chars) {
        [self output_Text:@(chars[0])];
        [self output_Text:@(chars[1])];
        [self output_Text:@(chars[2])];
    }
}






//明日计划;
//1) Output在使用多参数时,或者反应标识时,代码定义死的函数,会使这会变的非常不灵活;
//2) 所以应该把outputText,outputFace,outputReactor合并为一个方法; (把text,face都作为dS标识参数传递)
//3) 或者仅合并为2个(主动输出 & 反射输出)
//4) 即:(output_Object:dataSource:paramNum:);和(output_Reactor:paramNum:runBlock:)





/**
 *  MARK:--------------------反射输出器--------------------
 *  @params rds         : 先天反射标识 (作为dataSource的后辍);
 *  @params paramNum    : 参数值 (目前仅支持1个)
 */
+(void) output_Reactor:(NSString*)rds paramNum:(NSNumber*)paramNum{
    if (paramNum) {
        //1. 广播执行;
        [[NSNotificationCenter defaultCenter] postNotificationName:kOutputObserver object:@{@"rds":STRTOOK(rds),@"paramNum":NUMTOOK(paramNum)}];
        
        //2. 将输出入网;(TODO:将入网改到tc处,dataOut处应该自行入网)
        [[AIThinkingControl shareInstance] commitOutputLog:NSStringFromClass(self) dataSource:STRTOOK(rds) outputObj:paramNum];
    }
}

@end
