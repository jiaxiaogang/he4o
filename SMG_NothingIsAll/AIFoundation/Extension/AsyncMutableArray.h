//
//  AsyncMutableArray.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/17.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------多线程数组--------------------
 *  @desc 多线程操作时不闪退;
 */
@interface AsyncMutableArray : NSObject

- (NSMutableArray *)array;
- (BOOL)containsObject:(id)anObject;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSEnumerator *)objectEnumerator; //枚举item
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray*)objs;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeLastObject;
- (void)removeObjectsInRange:(NSRange)range;
- (void) removeAllObjects;
- (void) forEach:(void(^)(id))itemBlock;

@end
