//
//  FeelValueModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeelHeader.h"


/**
 *  MARK:--------------------感觉一项属性的值--------------------
 */
@interface FeelValueModel : NSObject

//@property (assign, nonatomic) NSInteger fromFeelId;
@property (assign, nonatomic) NSInteger toFeelId;               //和谁比
@property (assign, nonatomic) ComparisonType comparisonType;    //比较结果(toFeelId/fromFeelId)
@property (assign, nonatomic) NSInteger rate;                   //倍率(toFeelId/fromFeelId)

@end
