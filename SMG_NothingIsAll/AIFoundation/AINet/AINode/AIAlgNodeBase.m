//
//  AIAlgNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeBase.h"

@implementation AIAlgNodeBase

-(NSMutableArray *)refPorts{
    if (_refPorts == nil) {
        _refPorts = [NSMutableArray new];
    }
    return _refPorts;
}

-(NSArray *)value_ps{
    if (_value_ps == nil) {
        _value_ps = [NSArray new];
    }
    return _value_ps;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
        self.value_ps = [aDecoder decodeObjectForKey:@"value_ps"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.refPorts forKey:@"refPorts"];
    [aCoder encodeObject:self.value_ps forKey:@"value_ps"];
}

@end
