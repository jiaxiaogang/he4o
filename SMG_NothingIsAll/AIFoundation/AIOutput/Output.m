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

+(void) output_Text:(char)c{
    Output *op = [Output sharedInstance];
    if (op.delegate && [op.delegate respondsToSelector:@selector(output_Text:)]) {
        NSString *text = STRFORMAT(@"%d",c);
        [op.delegate output_Text:text];
    }
    
    //2. 将输出入网;
    [[AIThinkingControl shareInstance] commitOutputLog:NSStringFromClass(self) dataTo:@"output_Text:" outputObj:@(c)];
}

+(void) output_Face:(AIMoodType)type{
    if (type == AIMoodType_Anxious) {
        const char *chars = [@"😭" UTF8String];
        [self output_Text:chars[0]];
    }else if(type == AIMoodType_Satisfy){
        const char *chars = [@"😃" UTF8String];
        [self output_Text:chars[0]];
    }
}

@end
