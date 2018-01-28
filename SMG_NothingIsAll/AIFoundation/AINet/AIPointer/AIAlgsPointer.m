//
//  AIAlgsPointer.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/1/28.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAlgsPointer.h"

@implementation AIAlgsPointer

+(AIAlgsPointer*) initWithAlgsClass:(Class)algsClass algsName:(NSString*)algsName {
    AIAlgsPointer *pointer = [[AIAlgsPointer alloc] init];
    pointer.algsClass = NSStringFromClass(algsClass);
    pointer.algsName = STRTOOK(algsName);
    return pointer;
    
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.algsClass = [aDecoder decodeObjectForKey:@"algsClass"];
        self.algsName = [aDecoder decodeObjectForKey:@"algsName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.algsClass forKey:@"algsClass"];
    [aCoder encodeInteger:self.algsName forKey:@"algsName"];
}

@end

