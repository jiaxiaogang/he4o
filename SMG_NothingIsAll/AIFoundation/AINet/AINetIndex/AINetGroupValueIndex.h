//
//  AINetGroupValueIndex.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/27.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINetGroupValueIndex : NSObject

//MARK:===============================================================
//MARK:                     < 主方法：存取 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新一条gNode到索引序列--------------------
 */
+(void) updateGVIndex:(AIGroupValueNode*)gNode;

/**
 *  MARK:--------------------根据gNode取索引序列--------------------
 */
+(NSArray*) getGVIndex:(AIGroupValueNode*)gNode;

@end
