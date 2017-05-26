//
//  AIString.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIString.h"

@interface AIString ()

@property (strong,nonatomic) NSMutableArray *content;//AIChar.pointer数组;

@end

@implementation AIString

+(id)initWithContent:(id)content{
    AIString *value = [[AIString alloc] init];
    
    NSString *contentStr = STRTOOK(content);
    for (NSInteger i = 0; i < contentStr.length; i++) {
        unichar c = [contentStr characterAtIndex:i];
        AIChar *aiChar = [AIChar initWithContent:c];
        [value.content addObject:aiChar.pointer];
    }
    
    [AIString insertToDB:value];
    return value;
}

/**
 *  MARK:--------------------private--------------------
 */
- (nonnull NSMutableArray*) content {
    if (_content == nil) {
        _content = [[NSMutableArray alloc] init];
    }
    return _content;
}

/**
 *  MARK:--------------------public--------------------
 */
- (AIChar*)characterAtIndex:(NSUInteger)index{
    if (index < self.content.count) {
        AIPointer *pointer = [self.content objectAtIndex:index];
        return [NSClassFromString(pointer.pClass) searchSingleWithWhere:[DBUtils sqlWhere_RowId:pointer.pId] orderBy:nil];
    }
    return nil;
}

- (BOOL)isEqualToString:(AIString*)str {
    str = AISTRTOOK(str);
    if (self.content.count == str.content.count) {
        for (NSInteger i = 0; i < self.content.count; i++) {
            if(![self.content[i] isEqual:str.content[i]]){
                return false;
            }
        }
        return true;
    }
    return false;
}
@end
