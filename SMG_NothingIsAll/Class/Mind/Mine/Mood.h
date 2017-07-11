//
//  Mood.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//将要废弃的类...
/**
 *  MARK:--------------------mind元:"心情"--------------------
 *  受:Hobby,Demand,Mine所影响;三者各有其影响策略;
 */
@class MindStrategyModel;
@interface Mood : NSObject

-(id) initWithType:(MoodType)type value:(int)value;
@property (assign, nonatomic,readonly) int value;
@property (assign, nonatomic,readonly) MoodType type;

-(MindStrategyModel*) getStrategyModel;

@end
