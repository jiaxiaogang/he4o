//
//  AIString.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------字符串--------------------
 *  //存AIChar数组;
 */
@class AIChar;
@interface AIString : AIObject

- (nonnull NSMutableArray*) content;
- (AIChar*)characterAtIndex:(NSUInteger)index;
- (BOOL)isEqualToString:(AIString*_Nullable)str;

@end
