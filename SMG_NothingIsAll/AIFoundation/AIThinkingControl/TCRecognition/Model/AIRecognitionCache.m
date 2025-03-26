//
//  AIRecognitionCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIRecognitionCache.h"

@implementation AIRecognitionCache

- (NSMutableDictionary *)cacheDic {
    if (!_cacheDic) _cacheDic = [[NSMutableDictionary alloc] init];
    return _cacheDic;
}

-(id) getCache:(id)key cacheBlock:(id(^)())cacheBlock {
    id cache = [self.cacheDic objectForKey:key];
    if (cache) self.hitNum++; else self.missNum++;
    if (!cache && cacheBlock) {
        cache = cacheBlock();
        [self.cacheDic setObject:cache forKey:key];
    }
    return cache;
}

@end
