//
//  BirdView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodView;
@interface BirdView : UIView

//飞
-(void) fly:(CGFloat)x y:(CGFloat)y;


/**
 *  MARK:--------------------视觉--------------------
 *  1. 目前是被动视觉,
 *  2. 随后有需要可以改为主动视觉 (0.3s每桢)
 *  3. 主动视觉可以采用计时器和代理scan来实现;
 */
-(void) see:(UIView*)view;


//吃(坚果)
-(void) eat:(FoodView*)foodView;

@end
