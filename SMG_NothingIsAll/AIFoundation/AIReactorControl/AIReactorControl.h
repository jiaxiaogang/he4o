//
//  AIReactorControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------反应控制器 (中脑)--------------------
 *  1. 主要负责信息向算法皮层传递;
 *  2. 及对信息的反射做出处理;
 */
@class ImvAlgsModelBase;
@interface AIReactorControl : NSObject

+(AIReactorControl*) shareInstance;


/**
 *  MARK:--------------------先天mindValue工厂--------------------
 */
-(ImvAlgsModelBase*) createMindValue:(MVType)type value:(NSInteger)value;


/**
 *  MARK:--------------------反射情绪--------------------
 */
-(void) createReactor:(AIMoodType)moodType;

-(void) commitInput:(id)input;
-(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to;
-(void) commitCustom:(CustomInputType)type value:(NSInteger)value;
-(void) commitView:(UIView*)selfView targetView:(UIView*)targetView;
-(void) commitReactor:(NSString*)rds;

@end
