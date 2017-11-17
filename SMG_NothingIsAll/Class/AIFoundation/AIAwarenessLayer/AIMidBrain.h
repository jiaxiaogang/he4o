//
//  AIMidBrain.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIMidBrain : NSObject

/**
 *  MARK:--------------------先天mindValue工厂--------------------
 */
-(void) createMindValue;


/**
 *  MARK:--------------------反射情绪--------------------
 */
-(void) createMood:(AIMoodType)moodType;

@end
