//
//  AINetCache.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2018/1/5.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetCache.h"
#import "AIPointer.h"

@interface AINetCache()

@property (strong,nonatomic) NSMutableDictionary *cache;

@end

@implementation AINetCache

static AINetCache *_instance;
+(AINetCache*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINetCache alloc] init];
    }
    return _instance;
}

-(NSMutableDictionary *)cache{
    if (_cache == nil) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    return _cache;
}

-(id) objectForKey:(AIPointer*)key{
    if (ISOK(key, AIPointer.class)) {
        for (AIPointer *p in self.cache.allKeys) {
            if (p.pointerId == key.pointerId) {
                return [self.cache objectForKey:p];
            }
        }
    }
    return nil;
}

@end
