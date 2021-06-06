//
//  MemManager.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/6.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------记忆管理器--------------------
 *  @desc 由原本清空记忆的功能,以及记忆git备份工具的设想而来;
 */
@interface MemManager : NSObject

/**
 *  MARK:--------------------清除记忆--------------------
 */
+(void) removeAllMemory;

/**
 *  MARK:--------------------保存记忆--------------------
 */
+(void) saveAllMemory:(NSString*)saveName;

/**
 *  MARK:--------------------恢复记忆--------------------
 */
+(void) readAllMemory:(NSString*)readName;

@end
