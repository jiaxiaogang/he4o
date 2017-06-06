//
//  ThinkControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThinkControlDelegate <NSObject>

-(int) thinkControl_GetMoodValue:(AIPointer*)pointer;

@end

/**
 *  MARK:--------------------思考控制器--------------------
 */
@class Decision,Understand;
@interface ThinkControl : NSObject

@property (weak, nonatomic) id<ThinkControlDelegate> delegate;
@property (strong,nonatomic) Understand *understand;
@property (strong,nonatomic) Decision *decision;

-(void) commitDemand:(id)demand withType:(MindType)type;
-(void) commitUnderstandByShallow:(id)data;//浅理解
-(void) commitUnderstandByDeep:(id)data;//深理解

@end
