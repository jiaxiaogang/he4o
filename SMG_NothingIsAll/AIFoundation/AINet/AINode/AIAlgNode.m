//
//  AIAlgNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAlgNode.h"

@implementation AIAlgNode

-(NSMutableArray *)absPorts{
    if (_absPorts == nil) {
        _absPorts = [NSMutableArray new];
    }
    return _absPorts;
}

-(NSMutableArray *)refPorts{
    if (_refPorts == nil) {
        _refPorts = [NSMutableArray new];
    }
    return _refPorts;
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
    [aCoder encodeObject:self.refPorts forKey:@"refPorts"];
}

@end
