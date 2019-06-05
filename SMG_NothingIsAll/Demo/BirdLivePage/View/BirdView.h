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
-(UIView*) birdView_GetPageView;
-(CGRect) birdView_GetSeeRect;//视觉范围 (仅能看到范围内的view)

@end

@class FoodView;
@interface BirdView : UIView

@property (weak,nonatomic) id<BirdViewDelegate> delegate;

-(void) fly:(CGFloat)value;//飞


/**
 *  MARK:--------------------视觉--------------------
 *  1. 目前是被动视觉,
 *  2. 随后有需要可以改为主动视觉 (0.3s每桢)
 *  3. 主动视觉可以采用计时器和代理scan来实现;
 */
-(void) see:(UIView*)view;


/**
 *  MARK:--------------------触碰嘴--------------------
 *  1. 引起吸吮反射;
 *
 *  代码思路...
 *  1) 刺激引发he反射;
 *  2) 反射后开吃 (he主动调用eat());
 *  3) eat()中, 销毁food,并将产生的mv传回给he;
 *
 *  代码实践...
 *  1) 定义一个"反射标识";
 *  2) 在output中,写eat()的反射调用;
 *  3) "反射码"作为dataSource传递给outLog,可被CanOut判定true,并进行后天输出eat();
 *
 */
-(void) touchMouth;
-(void) touchWing;

@end
