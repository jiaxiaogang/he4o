//
//  Mood.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Mood.h"

@implementation Mood


/**
 *  MARK:--------------------心情变化--------------------
 */
-(void) changeSadHappyValue:(int)value{
    
    //1,sadHappyValue
    self.sadHappyValue += value;
    self.sadHappyValue = MIN(self.sadHappyValue, 10);
    self.sadHappyValue = MAX(self.sadHappyValue, -10);
    
    //2,lastChangeTime
    self.lastChangeTime = [NSDate date].timeIntervalSince1970;
}

-(void) refreshDecisionByOutputTask:(id)outputTask{
    //某心理因素对输出决策的影响处理;
}


@end
