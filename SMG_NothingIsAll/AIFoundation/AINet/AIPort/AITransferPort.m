//
//  AITransferPort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferPort.h"

@implementation AITransferPort

+(AITransferPort*) newWithScene:(AIKVPointer*)selfCanset scene:(AIKVPointer*)scene canset:(AIKVPointer*)canset {
    AITransferPort *result = [[AITransferPort alloc] init];
    result.selfCanset = selfCanset;
    result.scene = scene;
    result.canset = canset;
    return result;
}

-(BOOL) isEqual:(AITransferPort*)object{
    if (ISOK(object, AITransferPort.class)) {
        return [self.selfCanset isEqual:object.selfCanset] && [self.scene isEqual:object.scene] && [self.canset isEqual:object.canset];
    }
    return false;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.selfCanset = [coder decodeObjectForKey:@"selfCanset"];
        self.scene = [coder decodeObjectForKey:@"scene"];
        self.canset = [coder decodeObjectForKey:@"canset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.selfCanset forKey:@"selfCanset"];
    [coder encodeObject:self.scene forKey:@"scene"];
    [coder encodeObject:self.canset forKey:@"canset"];
}

@end
