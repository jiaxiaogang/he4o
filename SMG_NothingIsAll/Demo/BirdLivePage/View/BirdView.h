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

//视觉
-(void) see:(UIView*)view;

//吃(坚果)
-(void) eat:(FoodView*)foodView;

@end
