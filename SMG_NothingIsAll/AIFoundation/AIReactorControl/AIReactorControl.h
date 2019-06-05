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


/**
 *  MARK:--------------------先天mindValue工厂--------------------
 */
+(ImvAlgsModelBase*) createMindValue:(MVType)type value:(NSInteger)value;


/**
 *  MARK:--------------------反射情绪--------------------
 */
+(void) createReactor:(AIMoodType)moodType;

+(void) commitInput:(id)input;
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to;
+(void) commitCustom:(CustomInputType)type value:(NSInteger)value;
+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect;

/**
 *  MARK:--------------------提交反射反应--------------------
 *  1. 由外围神经提交一个反射信号;
 *  2. ReactorControl在收到信号后,响应反射;
 *  3. 并把反射执行的outLog构建到网络中;
 *
 *  目的: 是让he学会自主使用某外围功能;
 *  备注: 目前支持1个nsnumber参数; (也可以暂不支持参数)
 *
 *  @param rds      : 反射标识
 *  @param datas    : 要反射执行的参数 (吸吮力度或哭的表情)
 *
 */
+(void) commitReactor:(NSString*)rds datas:(NSArray*)datas;
+(void) commitReactor:(NSString*)rds;

@end
