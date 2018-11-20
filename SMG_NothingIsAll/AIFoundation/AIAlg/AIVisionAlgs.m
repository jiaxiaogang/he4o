//
//  AIVisionAlgs.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/15.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIVisionAlgs.h"
#import "AIVisionAlgsModel.h"
#import "AIThinkingControl.h"
#import "XGRedis.h"

@implementation AIVisionAlgs

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView{
    NSLog(@"对小鸟的视觉进行算法处理");
    //1. 生成model
    AIVisionAlgsModel *model = [[AIVisionAlgsModel alloc] init];
    model.sizeWidth = [self sizeWidth:targetView];
    model.sizeHeight = [self sizeHeight:targetView];
    model.colorRed = [self colorRed:targetView];
    model.colorGreen = [self colorGreen:targetView];
    model.colorBlue = [self colorBlue:targetView];
    model.radius = [self radius:targetView];
    model.originX = [self originX:selfView target:targetView];
    model.originY = [self originY:selfView target:targetView];
    model.speed = [self speed:selfView target:targetView];
    
    //2. 传给thinkingControl
    [[AIThinkingControl shareInstance] commitInput:model];
}


//MARK:===============================================================
//MARK:                     < size >
//MARK:===============================================================
+(CGFloat) sizeWidth:(UIView*)target{
    if (target) return target.width;
    return 0;
}
+(CGFloat) sizeHeight:(UIView*)target{
    if (target) return target.width;
    return 0;
}


//MARK:===============================================================
//MARK:                     < color >
//MARK:===============================================================
+(NSInteger) colorRed:(UIView*)target{
    if (target) return target.backgroundColor.red * 255.0f;
    return 0;
}
+(NSInteger) colorGreen:(UIView*)target{
    if (target){
        return target.backgroundColor.green * 255.0f;
    }
    return 0;
}
+(NSInteger) colorBlue:(UIView*)target{
    if (target) return target.backgroundColor.blue * 255.0f;
    return 0;
}


//MARK:===============================================================
//MARK:                     < radius >
//MARK:===============================================================
+(CGFloat) radius:(UIView*)target{
    if (target) return target.layer.cornerRadius;
    return 0;
}


//MARK:===============================================================
//MARK:                     < origin >
//MARK:===============================================================
+(CGFloat) originX:(UIView*)selfView target:(UIView*)target{
    return [UIView convertWorldPoint:target].x - [UIView convertWorldPoint:selfView].x;
}
+(CGFloat) originY:(UIView*)selfView target:(UIView*)target{
    return [UIView convertWorldPoint:target].y - [UIView convertWorldPoint:selfView].y;
}


//MARK:===============================================================
//MARK:                     < speed >
//MARK:===============================================================

//目前简单粗暴两桢差值 (随后有需要改用微积分)
+(CGFloat) speed:(UIView*)selfView target:(UIView*)target{
    CGFloat speed = 0;
    CGPoint targetPoint = [UIView convertWorldPoint:target];
    CGPoint selfPoint = [UIView convertWorldPoint:selfView];
    CGFloat distanceX = (targetPoint.x - selfPoint.x);
    CGFloat distanceY = (targetPoint.y - selfPoint.y);
    CGFloat distance = sqrt(powf(distanceX, 2) + powf(distanceY, 2));
    
    NSString *key = STRFORMAT(@"%p_%p",selfView,target);
    NSObject *lastDistanceNum = [[XGRedis sharedInstance] objectForKey:key];
    if (ISOK(lastDistanceNum, NSNumber.class)) {
        CGFloat lastDistance = [((NSNumber*)lastDistanceNum) floatValue];
        speed = distance - lastDistance;
    }
    [[XGRedis sharedInstance] setObject:[NSNumber numberWithFloat:distance] forKey:key time:cRedisDefaultTime];
    return speed;
}


@end
