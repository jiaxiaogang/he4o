//
//  Mood.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mood.h"

@implementation Mood


-(void)setHappyValue:(int)happyValue{
    _happyValue = MAX(-10, MIN(happyValue, 10));//值只能在-10到10之间;
}

-(void) refreshDecisionByOutputTask:(id)outputTask{
    //某心理因素对输出决策的影响处理;
}



@end
