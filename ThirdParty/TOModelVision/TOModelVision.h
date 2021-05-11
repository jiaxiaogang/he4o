//
//  TOModelVision.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出短时记忆可视化--------------------
 */
@class TOModelBase;
@interface TOModelVision : NSObject

/**
 *  MARK:--------------------从当前到root可视化日志--------------------
 */
+(NSString*) cur2Root:(TOModelBase*)curModel;

@end
