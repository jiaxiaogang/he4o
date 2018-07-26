//
//  AIAbsCMVNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsCMVNode.h"


//MARK:===============================================================
//MARK:                     < AIAbsCMVNode >
//MARK:===============================================================
@implementation AIAbsCMVNode

- (NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [NSMutableArray new];
    }
    return _conPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.urgentTo_p = [aDecoder decodeObjectForKey:@"urgentTo_p"];
        self.delta_p = [aDecoder decodeObjectForKey:@"delta_p"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.absNode_p = [aDecoder decodeObjectForKey:@"absNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.urgentTo_p forKey:@"urgentTo_p"];
    [aCoder encodeObject:self.delta_p forKey:@"delta_p"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.absNode_p forKey:@"absNode_p"];
}

@end
