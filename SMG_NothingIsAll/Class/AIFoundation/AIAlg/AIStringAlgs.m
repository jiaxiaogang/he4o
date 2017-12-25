//
//  StringAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStringAlgs.h"
#import "AIValue.h"
#import "AIThinkingControl.h"
#import "AIStringAlgsModel.h"

@implementation AIStringAlgs

+(void) commitInput:(NSString*)input{
    if (STRISOK(input)) {
        //1. 算法运算
        AIStringAlgsModel *model = [[AIStringAlgsModel alloc] init];
        model.str = input;
        model.length = [self length:input];
        model.spell = [self spell:input];
        
        //2. 结果给Thinking
        [[AIThinkingControl shareInstance] activityByShallow:model];
    }
}

+(NSUInteger) length:(NSString*)str {
    if (STRISOK(str)) {
        return str.length;
    }
    return 0;
}

+(NSArray*) spell:(NSString*)str{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    str = STRTOOK(str);
    for (NSInteger i = 0; i < str.length; i ++) {
        [mArr addObject:[str substringWithRange:NSMakeRange(i, 1)]];
    }
    return mArr;
}

@end
