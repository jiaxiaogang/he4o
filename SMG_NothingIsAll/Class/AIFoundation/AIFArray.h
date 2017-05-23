//
//  AIFArray.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFObject.h"

/**
 *  MARK:--------------------数组(可变)--------------------
 *  指针数组;元素为PointerModel
 */
@interface AIFArray : AIFObject

+ (AIFArray*) initWithObjects:(AIFObject*)obj,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");
@property (strong,nonatomic) NSMutableArray *content;
-(void) addObject:(AIFObject*)obj;
-(void) removeObject:(AIFObject*)obj;
-(void) removeObjectFromAtIndex:(NSUInteger)index;
-(BOOL) containsObject:(AIFObject*)obj;
@end
