//
//  AICMVNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AICMVNodeBase.h"

@implementation AICMVNodeBase

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.urgentTo_p = [aDecoder decodeObjectForKey:@"urgentTo_p"];
        self.delta_p = [aDecoder decodeObjectForKey:@"delta_p"];
        self.foNode_p = [aDecoder decodeObjectForKey:@"foNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.urgentTo_p forKey:@"urgentTo_p"];
    [aCoder encodeObject:self.delta_p forKey:@"delta_p"];
    [aCoder encodeObject:self.foNode_p forKey:@"foNode_p"];
}

@end
