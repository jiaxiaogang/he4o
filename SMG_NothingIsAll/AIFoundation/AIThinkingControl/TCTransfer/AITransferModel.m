//
//  AITransferModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/18.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferModel.h"

@implementation AITransferModel

+(AITransferModel*) newWithScene:(AIKVPointer*)scene canset:(AIKVPointer*)canset {
    AITransferModel *result = [[AITransferModel alloc] init];
    result.scene = scene;
    result.canset = canset;
    return result;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.scene = [aDecoder decodeObjectForKey:@"scene"];
        self.canset = [aDecoder decodeObjectForKey:@"canset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.scene forKey:@"scene"];
    [aCoder encodeObject:self.canset forKey:@"canset"];
}

@end
