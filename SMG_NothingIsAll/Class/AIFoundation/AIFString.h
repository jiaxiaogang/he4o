//
//  AIFString.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFObject.h"

/**
 *  MARK:--------------------字符串--------------------
 *  //存AIFChar数组;
 */
@class AIFChar;
@interface AIFString : AIFObject

- (nonnull NSMutableArray*) content;
- (AIFChar*_Nullable)characterAtIndex:(NSUInteger)index;
- (BOOL)isEqualToString:(AIFString*_Nullable)str;

@end
