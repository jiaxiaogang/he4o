//
//  AITransferPort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferPort.h"

@implementation AITransferPort

+(AITransferPort*) newWithFScene:(AIKVPointer*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps {
    AITransferPort *result = [[AITransferPort alloc] init];
    result.fScene = fScene;
    result.fCanset = fCanset.p;
    result.fCansetHeader = [NSString md5:[SMGUtils convertPointers2String:fCanset.content_ps]];
    result.iScene = iScene;
    result.iCansetHeader = [NSString md5:[SMGUtils convertPointers2String:iCansetContent_ps]];
    return result;
}

-(BOOL) isEqual:(AITransferPort*)object{
    if (ISOK(object, AITransferPort.class)) {
        //2. 对比scene层;
        BOOL equal2 = [self.fScene isEqual:object.fScene] && [self.iScene isEqual:object.iScene];
        if (!equal2) return false;
        
        //3. 对比canset层;
        BOOL equal3 = [self.fCanset isEqual:object.fCanset] && [self.iCansetHeader isEqualToString:object.iCansetHeader];
        if (!equal3) return false;
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
        self.fCansetHeader = [coder decodeObjectForKey:@"fCansetHeader"];
        self.iScene = [coder decodeObjectForKey:@"iScene"];
        self.iCansetHeader = [coder decodeObjectForKey:@"iCansetHeader"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fScene forKey:@"fScene"];
    [coder encodeObject:self.fCanset forKey:@"fCanset"];
    [coder encodeObject:self.fCansetHeader forKey:@"fCansetHeader"];
    [coder encodeObject:self.iScene forKey:@"iScene"];
    [coder encodeObject:self.iCansetHeader forKey:@"iCansetHeader"];
}

@end
