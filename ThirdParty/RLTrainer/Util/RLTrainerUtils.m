//
//  RLTrainerUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/5.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RLTrainerUtils.h"

@implementation RLTrainerUtils

+(CGFloat) onRoadYPos:(CGFloat)birdPosY{
    //1. 屏幕中心Y;
    CGFloat screenCenterY = ScreenHeight * 0.5f;
    CGFloat halfRoadHeight = 50,birdHeight = 30;
    CGFloat distanceCenterY = screenCenterY - birdPosY;
    
    //2. 偏上为0到1,偏下为0到-1 (0为中心,1和-1是路边缘点);
    CGFloat result = distanceCenterY / (halfRoadHeight + birdHeight);
    return result;
}

+(NSString*) onRoadYPosDesc:(CGFloat)birdPosY{
    CGFloat yPos = [self onRoadYPos:birdPosY];
    if (yPos > 1) {
        return @"路上";
    }else if (yPos > 0) {
        return STRFORMAT(@"偏上%.1f",yPos);
    }else if (yPos == 0) {
        return @"正中";
    }else if (yPos > -1) {
        return STRFORMAT(@"偏下%.1f",-yPos);
    }else{
        return @"路下";
    }
}

@end
