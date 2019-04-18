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

-(NSArray *)content_ps{
    if (_content_ps == nil) {
        _content_ps = [NSArray new];
    }
    return _content_ps;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
        self.content_ps = [aDecoder decodeObjectForKey:@"content_ps"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.refPorts forKey:@"refPorts"];
    [aCoder encodeObject:self.content_ps forKey:@"content_ps"];
}

@end
