//
//  AITransferPort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AITransferPort.h"

@implementation AITransferPort

+(AITransferPort*) newWithScene:(AIKVPointer*)scene canset:(AIKVPointer*)canset {
    AITransferPort *result = [[AITransferPort alloc] init];
    result.scene = scene;
    result.canset = canset;
    return result;
}

-(BOOL) isEqual:(AITransferPort*)object{
    if (ISOK(object, AITransferPort.class)) {
        return [self.scene isEqual:object.scene] && [self.canset isEqual:object.canset];
    }
    return false;
}

@end
