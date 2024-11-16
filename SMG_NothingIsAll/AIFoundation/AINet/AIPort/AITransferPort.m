//
//  AITransferPort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferPort.h"

@implementation AITransferPort

+(AITransferPort*) newWithFScene:(AIKVPointer*)fScene fCanset:(AIKVPointer*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps {
    AITransferPort *result = [[AITransferPort alloc] init];
    result.fScene = fScene;
    result.fCanset = fCanset;
    result.iScene = iScene;
    result.iCansetContent_ps = iCansetContent_ps;
    return result;
}

-(BOOL) isEqual:(AITransferPort*)object{
    if (ISOK(object, AITransferPort.class)) {
        return [self.fScene isEqual:object.fScene] && [self.fCanset isEqual:object.fCanset] && [self.iScene isEqual:object.iScene] && [self.iCansetContent_ps isEqual:object.iCansetContent_ps];
    }
    return false;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.fScene = [coder decodeObjectForKey:@"fScene"];
        self.fCanset = [coder decodeObjectForKey:@"fCanset"];
        self.iScene = [coder decodeObjectForKey:@"iScene"];
        self.iCansetContent_ps = [coder decodeObjectForKey:@"iCansetContent_ps"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fScene forKey:@"fScene"];
    [coder encodeObject:self.fCanset forKey:@"fCanset"];
    [coder encodeObject:self.iScene forKey:@"iScene"];
    [coder encodeObject:self.iCansetContent_ps forKey:@"iCansetContent_ps"];
}

@end
