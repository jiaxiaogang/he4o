//
//  AIChar.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIChar.h"

@implementation AIChar

+(AIChar *) initWithContent:(unichar)content{
    AIChar *value = [AIChar searchSingleWithWhere:[DBUtils sqlWhere_K:@"content" V:@(content)] orderBy:nil];
    if (value) {
        return value;
    }else{
        value = [[AIChar alloc] init];
        value.content = content;
        [AIChar insertToDB:value];
        return value;
    }
}

+(AIChar *) initWithContentByString:(NSString *)str {
    unichar content = 0;
    if (STRISOK(str)) {
        content = [str characterAtIndex:0];
    }
    return [self initWithContent:content];
}



@end
