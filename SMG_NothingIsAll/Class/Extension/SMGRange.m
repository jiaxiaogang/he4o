//
//  SMGRange.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGRange.h"

@implementation SMGRange

+(SMGRange*) rangeWithLocation:(NSInteger)location length:(NSInteger)length{
    SMGRange *range = [[SMGRange alloc] init];
    range.location = MAX(0, location);
    range.length = MAX(0, length);
    return range;
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.location = [aDecoder decodeIntegerForKey:@"location"];
        self.length = [aDecoder decodeIntegerForKey:@"length"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.location forKey:@"location"];
    [aCoder encodeInteger:self.length forKey:@"length"];
}

@end
