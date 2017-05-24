//
//  AIFArray.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFArray.h"

@interface AIFArray ()

@property (strong,nonatomic) NSMutableArray *content;

@end

@implementation AIFArray

+ (AIFArray*) initWithObjects:(AIFObject*)obj,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead"){
    AIFArray *value = [[AIFArray alloc] init];
    
    va_list argList;
    if (obj) {
        [value addObject:obj];
        va_start(argList, obj);
        AIFObject* arg = va_arg(argList, id);
        while (arg) {
            [value addObject:arg];
            arg = va_arg(argList, id);
        }
        va_end(argList);
    }
    
    [AIFArray insertToDB:value];
    return value;
}

/**
 *  MARK:--------------------private--------------------
 */
-(nonnull NSMutableArray*) content{
    if (_content == nil) {
        _content = [[NSMutableArray alloc] init];
    }
    return _content;
}

/**
 *  MARK:--------------------public--------------------
 */
-(void) addObject:(AIFObject*)obj{
    if (obj) {
        [self.content addObject:obj.pointer];
    }else{
        NSLog(@"!!!数据为空");
    }
}

-(void) removeObject:(AIFObject*)obj{
    if (obj) {
        [self.content removeObject:obj.pointer];
    }
}

-(void) removeObjectFromAtIndex:(NSUInteger)index{
    [self.content removeObjectAtIndex:index];
}

-(BOOL) containsObject:(AIFObject*)obj{
    if (obj) {
        return [self.content containsObject:obj.pointer];
    }
    return false;
}

-(id) objectAtIndex:(NSUInteger)index{
    if (index < self.content.count) {
        return self.content[index];
    }else{
        NSLog(@"!!!Index越界");
        return nil;
    }
}

@end
