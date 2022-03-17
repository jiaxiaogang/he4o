//
//  TOMVision2.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/13.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMVision2 : UIView

@property (assign, nonatomic) BOOL forceMode; //强力模式 (在此模式下,即使UI未展示,也会强行加入node);

/**
 *  MARK:--------------------设置内容--------------------
 */
-(void) updateLoopId;
-(void) updateFrame;

/**
 *  MARK:--------------------清空网络--------------------
 */
-(void) clear;

//开关
-(void) open;
-(void) close;

/**
 *  MARK:--------------------在强行工作模式下执行block--------------------
 */
-(void) invokeForceMode:(void(^)())block;

@end
