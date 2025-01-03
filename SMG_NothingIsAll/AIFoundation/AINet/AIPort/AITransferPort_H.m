//
//  AITransferPort_H.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/1/4.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AITransferPort_H.h"

@implementation AITransferPort_H

+(AITransferPort_H*) newWithFScene_H:(AIKVPointer*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps
                           fRScene:(AIFoNodeBase*)fRScene iRScene:(AIFoNodeBase*)iRScene {
    AITransferPort_H *result = [[AITransferPort_H alloc] init];
    result.fScene = fScene;
    result.fCanset = fCanset.p;
    result.fCansetHeader = [NSString md5:[SMGUtils convertPointers2String:fCanset.content_ps]];
    result.iScene = iScene;
    result.iCansetHeader = [NSString md5:[SMGUtils convertPointers2String:iCansetContent_ps]];
    
    result.fRScene = fRScene.p;
    result.iRScene = iRScene.p;
    return result;
}

-(BOOL) isEqual:(AITransferPort_H*)object{
    if (ISOK(object, AITransferPort_H.class)) {
        //1. 如果是H时,先对比下RCanset,不通过时直接返回false;
        BOOL equal1 = [self.fRScene isEqual:object.fRScene] && [self.iRScene isEqual:object.iRScene];
        if (!equal1) return false;
        
        //2. 对比scene层 和 canset层;
        return [super isEqual:object];
    }
    return false;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.fRScene = [coder decodeObjectForKey:@"fRScene"];
        self.iRScene = [coder decodeObjectForKey:@"iRScene"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.fRScene forKey:@"fRScene"];
    [coder encodeObject:self.iRScene forKey:@"iRScene"];
}

@end
