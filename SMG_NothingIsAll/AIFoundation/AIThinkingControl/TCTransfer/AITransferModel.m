//
//  AITransferModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/18.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferModel.h"

@implementation AITransferModel

+(AITransferModel*) newWithCansetTo:(AIKVPointer*)canset {
    AITransferModel *result = [[AITransferModel alloc] init];
    result.canset = canset;
    return result;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.canset = [aDecoder decodeObjectForKey:@"canset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.canset forKey:@"canset"];
}

@end
