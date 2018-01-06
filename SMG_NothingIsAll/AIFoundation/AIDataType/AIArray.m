//
//  AIArray.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIArray.h"
#import "AIPointer.h"

@interface AIArray ()

@property (strong,nonatomic) NSMutableArray *content;

@end

@implementation AIArray

+ (id) initWithObjects:(AIObject*)obj,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead"){
    Class arrClass = self.class;
    AIArray *value = [[arrClass alloc] init];
    
    va_list argList;
    if (obj) {
        [value addObject:obj];
        va_start(argList, obj);
        AIObject* arg = va_arg(argList, id);
        while (arg) {
            [value addObject:arg];
            arg = va_arg(argList, id);
        }
        va_end(argList);
    }
    //[arrClass insertToDB:value];
    return value;
}

+ (id) initWithAIArray:(AIArray*)arr{
    Class arrClass = self.class;
    AIArray *value = [[arrClass alloc] init];
    if (arr) {
        for (NSInteger i = 0; i < arr.count; i++) {
            [value addObject:[arr objectAtIndex:i]];
        }
    }
    //[arrClass insertToDB:value];
    return value;
}

+ (id) initWithArray:(NSArray*)arr{
    Class arrClass = self.class;
    AIArray *value = [[arrClass alloc] init];
    if (arr) {
        for (AIObject *item in arr) {
            [value addObject:item];
        }
    }
    //[arrClass insertToDB:value];
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
-(void) addObject:(AIObject*)obj{
    if (obj) {
        [self.content addObject:obj.pointer];
    }else{
        NSLog(@"!!!数据为空");
    }
}

-(void) addPointer:(AIPointer*)pointer{
    if (pointer) {
        [self.content addObject:pointer];
    }else{
        NSLog(@"!!!数据为空");
    }
}

-(void) removeObject:(AIObject*)obj{
    if (obj) {
        [self.content removeObject:obj.pointer];
    }
}

-(void) removeObjectFromAtIndex:(NSUInteger)index{
    [self.content removeObjectAtIndex:index];
}

-(BOOL) containsObject:(AIObject*)obj{
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

-(NSInteger) count{
    return self.content.count;
}

-(void) forIn:(AILogicKeyType(^)(AIPointer*))block{
    for (AIPointer *pointer in self.content) {
        if (block && pointer && [pointer isKindOfClass:[AIPointer class]]) {
            AILogicKeyType type = block(pointer);
            if (type == AILogicKeyType_Break) {
                break;
            }else if(type == AILogicKeyType_Continue){
                continue;
            }
        }
    }
}

@end
