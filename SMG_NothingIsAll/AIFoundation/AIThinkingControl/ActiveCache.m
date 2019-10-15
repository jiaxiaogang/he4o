//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "ActiveCache.h"

@implementation ActiveCache

-(NSMutableArray *)act_ps{
    if (!_act_ps) {
        _act_ps = [[NSMutableArray alloc] init];
    }
    return _act_ps;
}

-(void)add:(AIKVPointer *)act_p{
    if (act_p) {
        [self.act_ps addObject:_act_ps];
        self.act_ps = [[NSMutableArray alloc] initWithArray:ARR_SUB(self.act_ps, 0, MIN(self.act_ps.count, cActiveCacheLimit))];
    }
}

@end
