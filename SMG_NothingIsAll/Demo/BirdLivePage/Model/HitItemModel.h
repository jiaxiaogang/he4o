//
//  HitItemModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/5/21.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HitItemModel : NSObject

@property (assign, nonatomic) CGRect woodFrame; //记录木棒位置
@property (assign, nonatomic) CGRect birdFrame; //记录小鸟位置
@property (assign, nonatomic) long long time; //记录时间
@property (assign, nonatomic) CGFloat woodDuration; //持续时间
@property (assign, nonatomic) CGFloat birdDuration; //持续时间

@end
