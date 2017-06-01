//
//  Mine.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------饥饿程度--------------------
 */
typedef NS_ENUM(NSInteger, HungerStatus) {
    HungerStatus_Full           = 1,//饱
    HungerStatus_NotHunger      = 2,//不饿
    HungerStatus_LitterHunger   = 3,//有点饿
    HungerStatus_Hunger         = 4,//饿
    HungerStatus_VeryHunger     = 5,//非常饿
    HungerStatus_VeryVeryHunger = 6,//非常非常饿
};


@interface Mine : NSObject

+(HungerStatus) getHungerStatus;

@end
