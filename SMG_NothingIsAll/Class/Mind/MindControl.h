//
//  MindControll.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------Mind引擎(七情六欲)--------------------
 *
 *  驱动input
 *  驱动output
 */
@class Mood,HobbyModel,Mine;
@interface MindControl : NSObject

@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) HobbyModel *hobbyModel;
@property (strong,nonatomic) Mine *mine;

/**
 *  MARK:--------------------mine饥饿--------------------
 *  产生充电需求
 */
-(void) commitFromMineForHunger;

@end
