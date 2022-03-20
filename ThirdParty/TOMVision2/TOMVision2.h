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
-(void) updateFrame:(BOOL)newLoop;

/**
 *  MARK:--------------------清空网络--------------------
 */
-(void) clear;

//开关
-(void) open;
-(void) close;

@end
