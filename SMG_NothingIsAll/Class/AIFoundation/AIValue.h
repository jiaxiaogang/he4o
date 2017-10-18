//
//  AIValue.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/10/18.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@interface AIValue : AIObject

+(AIValue*) newWithDoubleValue:(double)doubleValue;
+(AIValue*) newWithIntegerValue:(NSInteger)integerValue ;

@property (assign, nonatomic) double doubleValue;

@end
