//
//  AIFChar.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFChar.h"

@implementation AIFChar

+(id) initWithContent:(unichar)content{
    AIFChar *value = [AIFChar searchSingleWithWhere:[DBUtils sqlWhere_K:@"content" V:@(content)] orderBy:nil];
    if (value) {
        return value;
    }else{
        value = [[AIFChar alloc] init];
        value.content = content;
        [AIFChar insertToDB:value];
        return value;
    }
}

-(BOOL) isEqual:(AIFChar*)obj{
    if (obj && [obj isKindOfClass:[AIFChar class]]) {
        return self.content == obj.content;
    }
    return false;
}


@end
