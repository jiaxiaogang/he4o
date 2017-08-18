//
//  AIChar.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIChar.h"

@implementation AIChar

+(AIChar *) newWithContent:(unichar)content{
    AIChar *value = [AIChar searchSingleWithWhere:[DBUtils sqlWhere_K:@"content" V:@(content)] orderBy:nil];
    if (value) {
        return value;
    }else{
        value = [[AIChar alloc] init];
        value.content = content;
        [AIChar ai_insertToDB:value];
        return value;
    }
}

+(AIChar *) newWithContentByString:(NSString *)str {
    unichar content = 0;
    if (STRISOK(str)) {
        content = [str characterAtIndex:0];
    }
    return [self newWithContent:content];
}



@end


/**
 *  MARK:--------------------本地存储--------------------
 */
@implementation AIChar (Store)



@end


