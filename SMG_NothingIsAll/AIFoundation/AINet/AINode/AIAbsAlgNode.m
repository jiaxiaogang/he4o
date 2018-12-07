//
//  AIAbsAlgNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsAlgNode.h"

@implementation AIAbsAlgNode

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [NSMutableArray new];
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
        self.value_p = [aDecoder decodeObjectForKey:@"value_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.value_p forKey:@"value_p"];
}

@end
