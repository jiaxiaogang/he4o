//
//  MemStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MemStore.h"

static MemStore *instance;

@implementation MemStore

+(id) shareInstance{
    if (instance == nil) {
        instance = [[MemStore alloc] init];
    }
    return instance;
}


-(NSMutableDictionary *)dic{
    if (_dic == nil) {
        _dic = [tmcache]
    }
}

@end
