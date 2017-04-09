//
//  MemStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MemStore.h"
#import "TMCache.h"



@implementation MemStore

-(NSMutableArray *)memArr{
    if (_memArr == nil) {
        _memArr = [[NSMutableArray alloc] initWithArray:[[TMCache sharedCache] objectForKey:@"MemStore_MemArr_Key"]];
    }
    return _memArr;
}


-(NSArray*) localArr{
    return [[TMCache sharedCache] objectForKey:@"MemStore_LocalArr_Key"];
}

@end
