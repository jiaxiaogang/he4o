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
    AIFChar *c = [AIFChar searchSingleWithWhere:[DBUtils sqlWhere_K:@"content" V:@(content)] orderBy:nil];
    if (c) {
        return c;
    }else{
        c = [[AIFChar alloc] init];
        return c;
    }
}

-(BOOL) isEqual:(AIFChar*)obj{
    if (obj && [obj isKindOfClass:[AIFChar class]]) {
        return self.content == obj.content;
    }
    return false;
}


@end
