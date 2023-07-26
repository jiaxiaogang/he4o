//
//  WoodView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ThrowTime 8.0f //满屏飞过用时

@protocol WoodViewDelegate <NSObject>

-(void) woodView_SetFramed;
-(void) woodView_WoodAnimationFinish;
-(void) woodView_FlyAnimationBegin:(CGFloat)aniDuration;

@end

@interface WoodView : HEView

@property (weak, nonatomic) id<WoodViewDelegate> delegate;

//复位
-(void) reset:(BOOL)hidden x:(CGFloat)x;
-(void) reset4StartAnimation:(CGFloat)throwX;
-(void) reset4EndAnimation;

/**
 *  MARK:--------------------扔出--------------------
 */
-(void) throwV5:(CGFloat)throwX time:(CGFloat)time distance:(CGFloat)distance invoked:(void(^)())invoked;

@end
