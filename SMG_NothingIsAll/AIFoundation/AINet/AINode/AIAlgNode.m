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

-(NSMutableArray *)values_p{
    if (_values_p == nil) {
        _values_p = [NSMutableArray new];
    }
    return _values_p;
}



/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.values_p = [aDecoder decodeObjectForKey:@"values_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
    [aCoder encodeObject:self.values_p forKey:@"values_p"];
}

@end
