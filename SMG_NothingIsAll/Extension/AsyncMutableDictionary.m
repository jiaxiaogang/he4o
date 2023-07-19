//
//  AsyncMutableDictionary.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/19.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import "AsyncMutableDictionary.h"

@interface AsyncMutableDictionary ()

@property (nonatomic, strong) NSMutableDictionary *dic;
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation AsyncMutableDictionary

- (instancetype)init {
    self = [super init];
    if (self) {
        _dic = [[NSMutableDictionary alloc] init];
        _syncQueue = dispatch_queue_create("AsyncMutableDictionary", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSMutableDictionary*)dictionary {
    __block NSMutableDictionary *safeDic;
    dispatch_sync(_syncQueue, ^{
        safeDic = self.dic;
    });
    return safeDic;
}

- (NSInteger)count {
    __block NSUInteger count;
    dispatch_sync(self.syncQueue, ^{
        count = self.dic.count;
    });
    return count;
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_barrier_async(self.syncQueue, ^{
        [self.dic removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(self.syncQueue, ^{
        [self.dic removeAllObjects];
    });
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    dispatch_barrier_async(self.syncQueue, ^{
        [self.dic setObject:anObject forKey:aKey];
    });
}

- (nullable id)objectForKey:(id)aKey {
    __block id item = nil;
    dispatch_sync(self.syncQueue, ^{
        item = [self.dic objectForKey:aKey];
    });
    return item;
}

- (NSArray *)allKeys {
    __block NSArray *keys;
    dispatch_sync(self.syncQueue, ^{
        keys = [self.dic allKeys];
    });
    return keys;
}

- (NSArray *)allValues {
    __block NSArray *values;
    dispatch_sync(self.syncQueue, ^{
        values = [self.dic allValues];
    });
    return values;
}

- (void)dealloc {
    if (_syncQueue) {
        _syncQueue = NULL;
    }
}

@end
