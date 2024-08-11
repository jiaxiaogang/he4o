//
//  HEView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/8/6.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------视觉可见的view--------------------
 *  @desc
 *      1. tag打visibleTag标记;
 *      2. 加了initTime,做唯一性判断 (因为ios已销毁的view会复用,导致内存地址并不表示唯一性) (参考20151-BUG11);
 */
@interface HEView : UIView

@property (assign, nonatomic) long long initTime;
-(void) initView;
-(void) initData;
-(void) initDisplay;

@end
