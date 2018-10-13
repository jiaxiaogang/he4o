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

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.foNode_p = [aDecoder decodeObjectForKey:@"foNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.foNode_p forKey:@"foNode_p"];
}

@end
