//
//  MindControll.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MindControlDelegate <NSObject>


-(void) mindControl_AddDemand:(id)demand withType:(MindType)type;//新增需求;

@end

/**
 *  MARK:--------------------Mind引擎(七情六欲)--------------------
 *
 *  驱动input
 *  驱动output
 */
@class Mood,Hobby,Mine;
@interface MindControl : NSObject

@property (weak, nonatomic) id<MindControlDelegate> delegate;
@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) Hobby *hobby;
@property (strong,nonatomic) Mine *mine;

/**
 *  MARK:--------------------是否喜欢pointer--------------------
 */
-(int) getMoodValue:(AIPointer*)pointer;

@end
