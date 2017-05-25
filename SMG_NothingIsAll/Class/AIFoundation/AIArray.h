//
//  AIArray.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------数组(可变)--------------------
 *  指针数组;元素为PointerModel
 */
@interface AIArray : AIObject <NSCoding>

+ (id) initWithObjects:(AIObject*)obj,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");
-(nonnull NSMutableArray*) content;
-(void) addObject:(AIObject*)obj;
-(void) removeObject:(AIObject*)obj;
-(void) removeObjectFromAtIndex:(NSUInteger)index;
-(BOOL) containsObject:(AIObject*)obj;
-(id) objectAtIndex:(NSUInteger)index;

@end
