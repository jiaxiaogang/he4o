//
//  AICMVNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AICMVNode.h"


//MARK:===============================================================
//MARK:                     < cmv节点 >
//MARK:===============================================================
@implementation AICMVNode

-(NSMutableArray *)absPorts{
    if (_absPorts == nil) {
        _absPorts = [NSMutableArray new];
    }
    return _absPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.delta_p = [aDecoder decodeObjectForKey:@"delta_p"];
        self.urgentTo_p = [aDecoder decodeObjectForKey:@"urgentTo_p"];
        self.cmvModel_p = [aDecoder decodeObjectForKey:@"cmvModel_p"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.delta_p forKey:@"delta_p"];
    [aCoder encodeObject:self.urgentTo_p forKey:@"urgentTo_p"];
    [aCoder encodeObject:self.cmvModel_p forKey:@"cmvModel_p"];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
}

@end
