//
//  ImvHungerModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ImvModelBase.h"

/**
 *  MARK:--------------------饥饿IMV模型--------------------
 */
@interface ImvHungerModel : ImvModelBase

@property (assign, nonatomic) CGFloat level;
@property (assign, nonatomic) HungerState state;

@end
