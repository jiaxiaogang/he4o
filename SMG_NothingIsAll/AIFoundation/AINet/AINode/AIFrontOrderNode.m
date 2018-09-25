//
//  AIFrontOrderNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIFrontOrderNode.h"

//MARK:===============================================================
//MARK:                     < 前因序列_节点(多级神经元) >
//MARK:===============================================================
@implementation AIFrontOrderNode

-(NSMutableArray *)orders_kvp{
    if (_orders_kvp == nil) {
        _orders_kvp = [[NSMutableArray alloc] init];
    }
    return _orders_kvp;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.orders_kvp = [aDecoder decodeObjectForKey:@"orders_kvp"];
        self.cmvModel_kvp = [aDecoder decodeObjectForKey:@"cmvModel_kvp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.orders_kvp forKey:@"orders_kvp"];
    [aCoder encodeObject:self.cmvModel_kvp forKey:@"cmvModel_kvp"];
}

@end
