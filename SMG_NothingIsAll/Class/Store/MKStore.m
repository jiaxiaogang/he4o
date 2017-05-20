//
//  MKStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MKStore.h"
#import "SMGHeader.h"
#import "StoreHeader.h"


@implementation MKStore

-(id) init{
    self = [super init];
    if (self) {
        self.textStore = [[TextStore alloc] init];
        self.objStore = [[ObjStore alloc] init];
        self.doStore = [[DoStore alloc] init];
    }
    return self;
}

@end
