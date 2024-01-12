//
//  TOMVision2.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/13.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMVision2 : UIView

/**
 *  MARK:--------------------设置内容--------------------
 */
-(void) updateFrame;

/**
 *  MARK:--------------------清空网络--------------------
 */
-(void) clear;

/**
 *  MARK:--------------------停止工作--------------------
 */
-(void) setStop:(BOOL)stop;

//开关
-(void) open;
-(void) close;

@end
