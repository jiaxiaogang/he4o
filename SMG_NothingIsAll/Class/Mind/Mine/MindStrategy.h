//
//  MindStrategy.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------精神策略--------------------
 *  1,用于描述每种精神的值;
 *  2,用来作"博弈"
 *  3,.....?由于饥饿引起的烦燥,等...
 *  4,双权重;
 *      先天定义权重;
 *      后天影响权重;
 */
@class MindStrategyModel;
@interface MindStrategy : NSObject

/**
 *  MARK:--------------------获取策略通用Model--------------------
 */
+(MindStrategyModel*) getModelWithMin:(NSInteger)min withMax:(NSInteger)max withOriValue:(NSInteger)oriValue withType:(MindType)type;

/**
 *  MARK:--------------------获取最需求策略--------------------
 */
+(MindStrategyModel*) getModelForDemandWithArr:(NSArray*)arr;

@end



@interface MindStrategyModel : NSObject

@property (assign, nonatomic) NSInteger value;//饱合度(0-100)
@property (assign, nonatomic) MindType type;

@end
