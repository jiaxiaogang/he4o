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
#import "UIView+Extension.h"

@implementation AIVisionAlgs

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect{
    //1. 数据准备;
    if (!selfView || !targetView) {
        return;
    }
    NSMutableArray *models = [[NSMutableArray alloc] init];
    NSMutableArray *views = [targetView subViews_AllDeepWithRect:rect];
    
    //2. 生成model
    for (UIView *curView in views) {
        AIVisionAlgsModel *model = [[AIVisionAlgsModel alloc] init];
        model.sizeWidth = [self sizeWidth:curView];
        model.sizeHeight = [self sizeHeight:curView];
        model.colorRed = [self colorRed:curView];
        model.colorGreen = [self colorGreen:curView];
        model.colorBlue = [self colorBlue:curView];
        model.radius = [self radius:curView];
        model.originX = [self originX:selfView target:curView];
        model.originY = [self originY:selfView target:curView];
        model.speed = [self speed:selfView target:curView];
        [models addObject:model];
    }
    
    //3. 传给thinkingControl
    [[AIThinkingControl shareInstance] commitInputWithModels:models];
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
    [[XGRedis sharedInstance] setObject:[NSNumber numberWithFloat:distance] forKey:key time:cRTDefault];
    return speed;
}


@end
