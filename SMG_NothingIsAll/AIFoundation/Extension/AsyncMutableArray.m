//
//  AsyncMutableArray.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/17.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import "AsyncMutableArray.h"

@interface AsyncMutableArray()

@property (strong, nonatomic) dispatch_queue_t syncQueue;
@property (strong, nonatomic) NSMutableArray *arr;

@end

@implementation AsyncMutableArray

-(instancetype)init {
    self = [super init];
    if (self) {
        NSString *identifier = [NSString stringWithFormat:@"<AsyncMutableArray>%p",self];
        self.syncQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_CONCURRENT);
        self.arr = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray *)array {
    __block NSMutableArray *safeArray;
    dispatch_sync(_syncQueue, ^{
        safeArray = self.arr;
    });
    return safeArray;
}

- (BOOL)containsObject:(id)anObject {
    __block BOOL isExist = NO;
    dispatch_sync(_syncQueue, ^{
        isExist = [self.arr containsObject:anObject];
    });
    return isExist;
}

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(_syncQueue, ^{
        count = self.arr.count;
    });
    return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id obj;
    dispatch_sync(_syncQueue, ^{
        if (index < [self.arr count]) {
            obj = self.arr[index];
        }
    });
    return obj;
}

- (NSUInteger)indexOfObject:(id)anObject {
    __block NSUInteger index = NSNotFound;
    dispatch_sync(_syncQueue, ^{
        for (int i = 0; i < [self.arr count]; i ++) {
            if ([self.arr objectAtIndex:i] == anObject) {
                index = i;
                break;
            }
        }
    });
    return index;
}

- (NSEnumerator *)objectEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(_syncQueue, ^{
        enu = [self.arr objectEnumerator];
    });
    return enu;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    dispatch_barrier_async(_syncQueue, ^{
        if (anObject && index <= [self.arr count]) {
            [self.arr insertObject:anObject atIndex:index];
        }
    });
}

- (void)addObject:(id)anObject {
    dispatch_barrier_async(_syncQueue, ^{
        if(anObject){
            [self.arr addObject:anObject];
        }
    });
}

- (void)addObjectsFromArray:(NSArray*)objs {
    dispatch_barrier_async(_syncQueue, ^{
        if(ARRISOK(objs)){
            [self.arr addObjectsFromArray:objs];
        }
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    dispatch_barrier_async(_syncQueue, ^{
        if (anObject && index < [self.arr count]) {
            [self.arr replaceObjectAtIndex:index withObject:anObject];
        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_barrier_async(_syncQueue, ^{
        if (index < [self.arr count]) {
            [self.arr removeObjectAtIndex:index];
        }
    });
}

- (void)removeObject:(id)anObject {
    dispatch_barrier_async(_syncQueue, ^{
        [self.arr removeObject:anObject];
    });
}

- (void)removeLastObject {
    dispatch_barrier_async(_syncQueue, ^{
        [self.arr removeLastObject];
    });
}

- (void)removeObjectsInRange:(NSRange)range {
    dispatch_barrier_async(_syncQueue, ^{
        [self.arr removeObjectsInRange:range];
    });
}

- (void) removeAllObjects {
    dispatch_barrier_async(_syncQueue, ^{
        [self.arr removeAllObjects];
    });
}

- (void) forEach:(void(^)(id))itemBlock {
    dispatch_barrier_async(_syncQueue, ^{
        for (id item in self.arr) {
            itemBlock(item);
        }
    });
}

- (void)dealloc {
    if (_syncQueue) {
        _syncQueue = NULL;
    }
}

@end
