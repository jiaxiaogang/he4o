//
//  AIHungerStateChangedModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@interface AIHungerStateChangedModel : AIObject

@property (assign, nonatomic) CGFloat level;    //电量(0-10)
@property (assign, nonatomic) HungerState state;

@end
