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
-(void) thinkControl_TurnDownDemand:(AIDemandModel*)model;  //驳回未能解决的demand;

@end

/**
 *  MARK:--------------------思考控制器--------------------
 */
@interface ThinkControl : NSObject

@property (weak, nonatomic) id<ThinkControlDelegate> delegate;
@property (strong,nonatomic,readonly) AIDemandModel *curDemand;//当前任务;

/**
 *  MARK:--------------------Understand(Input->Think)--------------------
 */
-(void) commitUnderstandByShallow:(id)data;//浅理解

/**
 *  MARK:--------------------Demand(Mind->Think)--------------------
 *  所有需求都是异步的;所以这里只作通知;
 */
//分析
-(void) commitMindValueNotice:(AIMindValueModel*)model;
-(void) commitMindModel:(id)m;   //提交来自Mind的模型;
/**
 *  MARK:--------------------Other--------------------
 */
-(void) setData:(AIDemandModel *)demand;
-(BOOL) isBusy;

@end
