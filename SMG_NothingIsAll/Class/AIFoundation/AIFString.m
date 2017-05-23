//
//  AIFString.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFString.h"

@implementation AIFString

+(id)initWithContent:(id)content{
    AIFString *value = [[AIFString alloc] init];
    value.content = [[NSMutableArray alloc] init];
    
    NSString *contentStr = STRTOOK(content);
    for (NSInteger i = 0; i < contentStr.length; i++) {
        unichar c = [contentStr characterAtIndex:i];
        AIFChar *aifChar = [AIFChar initWithContent:c];
        [value.content addObject:aifChar.pointer];
    }
    
    [AIFString insertToDB:value];
    return value;
}


- (AIFChar*)characterAtIndex:(NSUInteger)index{
    PointerModel *pointer = [self.content objectAtIndex:index];
    return [NSClassFromString(pointer.pointerClass) searchSingleWithWhere:[DBUtils sqlWhere_RowId:pointer.pointerId] orderBy:nil];
}

@end
