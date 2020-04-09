//
//  AIShortMemory.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/23.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMemory.h"
#import "AIPointer.h"

@interface AIShortMemory ()

@property (strong,nonatomic) NSMutableArray *protoCache;//瞬时记忆 (容量8)
@property (strong,nonatomic) NSMutableArray *matchCache;//瞬时match版 (以后逐步替代shortCache);

@end

@implementation AIShortMemory

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.protoCache = [[NSMutableArray alloc] init];
    self.matchCache = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

/**
 *  MARK:--------------------获取缓存--------------------
 *  @result notnull
 */
-(NSMutableArray*) shortCache:(BOOL)isMatch{
    return isMatch ? self.matchCache : self.protoCache;
}

-(void) addToShortCache_Ps:(NSArray*)ps isMatch:(BOOL)isMatch{
    NSMutableArray *cache = [self shortCache:isMatch];
    if (ARRISOK(ps)) {
        for (AIPointer *pointer in ps) {
            [cache addObject:pointer];
            if (cache.count > cShortMemoryLimit) {
                [cache removeObjectAtIndex:0];
            }
        }
    }
}

-(void) clear:(BOOL)isMatch{
    [[self shortCache:isMatch] removeAllObjects];
}

@end
