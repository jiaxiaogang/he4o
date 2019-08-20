//
//  StringAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStringAlgs.h"
#import "AIThinkingControl.h"

@implementation AIStringAlgs

+(void) commitInput:(NSString*)input{
    if (STRISOK(input)) {
        //1. 算法运算
        //2. 结果给Thinking
        
        //AIStringAlgsModel *model = [[AIStringAlgsModel alloc] init];
        //model.str = input;
        //model.length = [self length:input];
        //model.spell = [self spell:input];
        //[theTC commitInput:model];
        
        const char *chars = [input UTF8String];
        for (NSInteger i = 0; i < input.length; i ++) {
            AICharAlgsModel *model = [AICharAlgsModel new];
            model.c = chars[i];
            [theTC commitInput:model];
        }
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
    const char *chars = [str UTF8String];
    for (NSInteger i = 0; i < str.length; i ++) {
        //unichar c = [str characterAtIndex:i];
        char c = chars[i];
        [mArr addObject:@(c)];
    }
    return mArr;
}

@end




//MARK:===============================================================
//MARK:                     < String算法结果模型 >
//MARK:===============================================================
@implementation AIStringAlgsModel

@end




//MARK:===============================================================
//MARK:                     < char算法结果模型 >
//MARK:===============================================================
@implementation AICharAlgsModel : NSObject

@end
