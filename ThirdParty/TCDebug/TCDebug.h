//
//  TCDebug.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/20.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思维控制器调试器--------------------
 *  @desc 1. 使用方法: TCDebug(@"R8");TCDebug(@"R9");
 *        2. 功能说明: 打出的日志,R8用时表示在R8到R9之间的代码用时;
 */
@interface TCDebug : NSObject

-(void) updateOperCount:(NSString*)operater;
-(void) updateLoopId;

@end
