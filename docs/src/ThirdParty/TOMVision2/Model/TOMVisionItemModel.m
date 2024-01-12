//
//  TOMVisionItemModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVisionItemModel.h"

@implementation TOMVisionItemModel

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.roots = [aDecoder decodeObjectForKey:@"roots"];
        self.loopId = [aDecoder decodeIntegerForKey:@"loopId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.roots forKey:@"roots"];
    [aCoder encodeInteger:self.loopId forKey:@"loopId"];
}

@end
