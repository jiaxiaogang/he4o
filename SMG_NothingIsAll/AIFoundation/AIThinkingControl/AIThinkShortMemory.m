//
//  AIThinkShortMemory.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/23.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkShortMemory.h"
#import "AIPointer.h"

@interface AIThinkShortMemory ()

@property (strong,nonatomic) NSMutableArray *shortCache;//瞬时记忆 (容量8)

@end

@implementation AIThinkShortMemory


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(NSMutableArray*) shortCache{
    if (!_shortCache) {
        _shortCache = [[NSMutableArray alloc] init];
    }
    return _shortCache;
}

-(void) addToShortCache_Ps:(NSArray*)ps{
    if (ARRISOK(ps)) {
        for (AIPointer *pointer in ps) {
            [self.shortCache addObject:pointer];
            if (self.shortCache.count > 8) {
                [self.shortCache removeObjectAtIndex:0];
            }
        }
    }
}

-(void) clear{
    [self.shortCache removeAllObjects];
}

@end
