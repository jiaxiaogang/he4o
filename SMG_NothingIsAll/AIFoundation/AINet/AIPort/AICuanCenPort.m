//
//  AICuanCenPort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/16.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AICuanCenPort.h"

@implementation AICuanCenPort

+(AICuanCenPort*) newWithScene:(AIKVPointer*)scene canset:(AIKVPointer*)canset {
    AICuanCenPort *result = [[AICuanCenPort alloc] init];
    result.scene = scene;
    result.canset = canset;
    return result;
}

-(BOOL) isEqual:(AICuanCenPort*)object{
    if (ISOK(object, AICuanCenPort.class)) {
        return [self.scene isEqual:object.scene] && [self.canset isEqual:object.canset];
    }
    return false;
}

@end
