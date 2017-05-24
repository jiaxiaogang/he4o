//
//  AIFString.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFString.h"

@interface AIFString ()

@property (strong,nonatomic) NSMutableArray *content;//AIFChar.pointer数组;

@end

@implementation AIFString

+(id)initWithContent:(id)content{
    AIFString *value = [[AIFString alloc] init];
    
    NSString *contentStr = STRTOOK(content);
    for (NSInteger i = 0; i < contentStr.length; i++) {
        unichar c = [contentStr characterAtIndex:i];
        AIFChar *aifChar = [AIFChar initWithContent:c];
        [value.content addObject:aifChar.pointer];
    }
    
    [AIFString insertToDB:value];
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
- (AIFChar*)characterAtIndex:(NSUInteger)index{
    if (index < self.content.count) {
        PointerModel *pointer = [self.content objectAtIndex:index];
        return [NSClassFromString(pointer.pointerClass) searchSingleWithWhere:[DBUtils sqlWhere_RowId:pointer.pointerId] orderBy:nil];
    }
    return nil;
}

- (BOOL)isEqualToString:(AIFString*)str {
    str = AIFSTRTOOK(str);
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
