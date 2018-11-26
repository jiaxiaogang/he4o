//
//  BirdView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodView;
@protocol BirdViewDelegate <NSObject>

-(FoodView*) birdView_GetFoodOnMouth;

@end

@class FoodView;
@interface BirdView : UIView

@property (weak,nonatomic) id<BirdViewDelegate> delegate;

-(void) fly:(CGFloat)x y:(CGFloat)y;//飞


/**
 *  MARK:--------------------视觉--------------------
 *  1. 目前是被动视觉,
 *  2. 随后有需要可以改为主动视觉 (0.3s每桢)
 *  3. 主动视觉可以采用计时器和代理scan来实现;
 */
-(void) see:(UIView*)view;


//触碰嘴
-(void) touchMouth;

@end
