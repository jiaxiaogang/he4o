//
//  AINetAbsUtils.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"

@implementation AINetAbsUtils

+(AIPort*) searchPortWithTargetP:(AIKVPointer*)target_p fromPorts:(NSArray*)ports{
    for (AIPort *checkPort in ARRTOOK(ports)) {
        if (ISOK(checkPort, AIPort.class) && ISOK(checkPort.pointer, AIKVPointer.class)) {
            if ([checkPort.pointer isEqual:target_p]) {
                return checkPort;
            }
        }
    }
    return nil;
}

@end
