//
//  AIMoodModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIMoodModel : AIObject

-(id) initWithType:(MoodType)type value:(int)value;

@property (assign, nonatomic) int value;
@property (assign, nonatomic) MoodType type;

@end
