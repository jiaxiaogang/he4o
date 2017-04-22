//
//  UnderstandModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DoModel.h"

@implementation DoModel

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.fromMKId = [aDecoder decodeObjectForKey:@"fromMKId"];
        self.doType = [aDecoder decodeObjectForKey:@"doType"];
        self.toMKId = [aDecoder decodeObjectForKey:@"toMKId"];
        self.value = [aDecoder decodeObjectForKey:@"value"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fromMKId forKey:@"fromMKId"];
    [aCoder encodeObject:self.doType forKey:@"doType"];
    [aCoder encodeObject:self.toMKId forKey:@"toMKId"];
    [aCoder encodeObject:self.value forKey:@"value"];
}


@end
