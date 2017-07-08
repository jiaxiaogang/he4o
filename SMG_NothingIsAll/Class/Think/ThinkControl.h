//
//  ThinkControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThinkControlDelegate <NSObject>

-(id) thinkControl_GetMindValue:(AIPointer*)pointer;//对obj,char,或者其它复合的东西"偏好值";
-(NSString*) thinkControl_TurnDownDemand:(id)demand type:(MindType)type;  //驳回未能解决的demand;

@end

/**
 *  MARK:--------------------思考控制器--------------------
 */
@class Decision,Understand;
@interface ThinkControl : NSObject

@property (weak, nonatomic) id<ThinkControlDelegate> delegate;
@property (strong,nonatomic) Understand *understand;
@property (strong,nonatomic) Decision *decision;

-(void) commitUnderstandByShallow:(id)data;//浅理解
-(void) commitUnderstandByDeep:(id)data;//深理解


/**
 *  MARK:--------------------Demand--------------------
 */
//分析
-(void) commitDemand:(id)demand withType:(MindType)type;

@end
