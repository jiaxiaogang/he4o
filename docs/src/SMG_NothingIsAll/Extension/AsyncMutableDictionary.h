//
//  AsyncMutableDictionary.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/19.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncMutableDictionary : NSObject

- (NSMutableDictionary*)dictionary;
- (NSInteger)count;
- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (nullable id)objectForKey:(id)aKey;
- (NSArray *)allKeys;
- (NSArray *)allValues;

@end
