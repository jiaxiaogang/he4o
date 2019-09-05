//
//  AIThinkOutReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理性ThinkOut部分--------------------
 */
@class AICMVNodeBase,AIAlgNodeBase;
@interface AIThinkOutReason : NSObject

+(void) dataOut:(AIKVPointer*)targetAlg_p isNode:(AIAlgNodeBase*)isNode useNode:(AICMVNodeBase*)useNode;

@end
