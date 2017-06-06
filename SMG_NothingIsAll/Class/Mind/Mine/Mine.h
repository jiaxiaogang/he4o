//
//  Mine.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hunger.h"

@protocol MineDelegate <NSObject>

-(void) mine_HungerStateChanged:(HungerStatus)status;

@end


/**
 *  MARK:--------------------mind元:"精神自我"--------------------
 */
@class Mood,Hobby;
@interface Mine : NSObject

@property (weak, nonatomic) id<MineDelegate> delegate;
@property (strong,nonatomic) Hunger *hunger;
@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) Hobby *hobby;

@end
