//
//  TCDebug.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/20.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单次模块Debug性能调试器--------------------
 *  @desc 1. 使用方法: TCDebug(@"R8");TCDebug(@"R9");
 *        2. 使用说明: 每条显示的用时为,当上条到当前条执行间的代码用时;
 *  @常用 1. 常用于仅记录当前操作的统计情况; (使用方法:[theTC.tcDebug updateOperCount:@"youCodeBlockName"])
 *       2. 用于思维控制器中,将循环数,操作计数等记下来,相当于在XGDebug上封装了TC所需的一层附带数据 (但并没有由TCDebug调用XGDebug);
 *  @特性 1. 仅当前模块;   2. 每个TC在开头调用,结尾不调用(所以可查看当前TC的所有数据,直至下个TC开始);
 */
@interface TCDebug : NSObject

@property (assign, nonatomic) NSInteger lastRCount;//硬盘读数 (因为HD读写往往与性能关系密切,所以记录下)
@property (assign, nonatomic) NSInteger lastWCount;//硬盘写数 (因为HD读写往往与性能关系密切,所以记录下)

/**
 *  MARK:--------------------代码块报告--------------------
 */
-(void) updateOperCount:(NSString*)operater min:(NSInteger)min;
-(void) updateLoopId;

@end
