//
//  AIReactorControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,ImvModelBase;
@interface AIReactorControl : NSObject

+(AIReactorControl*) shareInstance;


/**
 *  MARK:--------------------先天mindValue工厂--------------------
 */
-(ImvModelBase*) createMindValue:(IMVType)type value:(NSInteger)value;


/**
 *  MARK:--------------------反射情绪--------------------
 */
-(void) createReactor:(AIMoodType)moodType;

-(void) commitInput:(id)input;
-(void) commitInputIMV:(IMVType)type value:(NSInteger)value;
-(void) commitCustom:(CustomInputType)type value:(NSInteger)value;

@end
