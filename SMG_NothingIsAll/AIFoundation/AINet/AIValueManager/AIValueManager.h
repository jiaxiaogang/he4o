//
//  AIValueManager.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/18.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIGroupValueNode;
@interface AIValueManager : NSObject

/**
 *  MARK:--------------------构建组码--------------------
 */
+(AIGroupValueNode*) createGroupValueNode:(NSArray*)content_ps conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut;

@end
