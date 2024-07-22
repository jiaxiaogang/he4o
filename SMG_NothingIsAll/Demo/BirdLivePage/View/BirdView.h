//
//  BirdView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodView.h"

@protocol BirdViewDelegate <NSObject>

-(NSArray *)birdView_GetFoodOnHit:(CGRect)birdStart birdEnd:(CGRect)birdEnd status:(FoodStatus)status;
-(UIView*) birdView_GetPageView;
-(CGRect) birdView_GetSeeRect;//视觉范围 (仅能看到范围内的view)
-(void) birdView_SetFramed;
-(void) birdView_FlyAnimationFinish;
-(void) birdView_FlyAnimationBegin:(CGFloat)aniDuration;
-(void) birdView_HungerEnd; //结束饥饿 (不饿了)

@end

@class FoodView;
@interface BirdView : UIView

@property (weak,nonatomic) id<BirdViewDelegate> delegate;
-(void) viewWillDisappear;

/**
 *  MARK:--------------------鸟飞过的坚果--------------------
 */
@property (strong, nonatomic) NSArray *hitFoods;

/**
 *  MARK:--------------------饿了在等吃状态--------------------
 *  @desc 如果等待期间吃不上则会更饿,如果吃上了就不会更饿 (参考28171-todo2)
 */
@property (assign, nonatomic) BOOL waitEat;


/**
 *  MARK:--------------------视觉--------------------
 *  1. 目前是被动视觉,
 *  2. 随后有需要可以改为主动视觉 (0.3s每桢)
 *  3. 主动视觉可以采用计时器和代理scan来实现;
 */
-(void) see:(UIView*)view fromObserver:(BOOL)fromObserver;


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

/**
 *  MARK:--------------------摸翅膀--------------------
 *  @param direction 从左顺时针,8个方向,分别为0-7;
 */
-(void) touchWing:(long)direction;

/**
 *  MARK:--------------------摸脚--------------------
 *  @param direction 从左顺时针,8个方向,分别为0-7;
 */
-(void) touchFoot:(long)direction;

/**
 *  MARK:--------------------痛--------------------
 */
-(void) hurt;

@end
