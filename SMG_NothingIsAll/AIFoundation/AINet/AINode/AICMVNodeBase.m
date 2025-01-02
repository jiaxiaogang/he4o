//
//  AICMVNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AICMVNodeBase.h"

@implementation AICMVNodeBase

-(NSMutableArray *)content_ps{
    return [[NSMutableArray alloc] initWithObjects:self.delta_p,self.urgentTo_p, nil];
}

-(NSMutableArray *)foPorts{
    if (!ISOK(_foPorts, NSMutableArray.class)) {
        _foPorts = [[NSMutableArray alloc] initWithArray:_foPorts];
    }
    return _foPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.urgentTo_p = [aDecoder decodeObjectForKey:@"urgentTo_p"];
        self.delta_p = [aDecoder decodeObjectForKey:@"delta_p"];
        self.foPorts = [aDecoder decodeObjectForKey:@"foPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.urgentTo_p forKey:@"urgentTo_p"];
    [aCoder encodeObject:self.delta_p forKey:@"delta_p"];
    [aCoder encodeObject:[self.foPorts copy] forKey:@"foPorts"];
}

@end
