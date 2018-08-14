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
        [[AIThinkingControl shareInstance] commitOutputLog:NSStringFromClass(self) dataTo:NSStringFromSelector(@selector(output_Text:)) outputObj:charNum];
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

@end
