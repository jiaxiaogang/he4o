//
//  AIAbsNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsNodeBase.h"

@implementation AIAbsNodeBase

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
    }
    return _conPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
}


@end
