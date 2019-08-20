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
#import "NSObject+Extension.h"

@implementation AIVisionAlgs

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView rect:(CGRect)rect{
    //1. 数据准备;
    if (!selfView || !targetView) {
        return;
    }
    NSMutableArray *dics = [[NSMutableArray alloc] init];
    NSMutableArray *views = [targetView subViews_AllDeepWithRect:rect];
    
    //2. 生成model
    for (UIView *curView in views) {
        if (curView.tag == visibleTag) {
            AIVisionAlgsModel *model = [[AIVisionAlgsModel alloc] init];
            model.sizeWidth = [self sizeWidth:curView];
            model.sizeHeight = [self sizeHeight:curView];
            model.colorRed = [self colorRed:curView];
            model.colorGreen = [self colorGreen:curView];
            model.colorBlue = [self colorBlue:curView];
            model.radius = [self radius:curView];
            model.speed = [self speed:selfView target:curView];
            model.direction = [self direction:selfView target:curView];
            model.distance = [self distance:selfView target:curView];
            model.border = [self border:curView];
            NSMutableDictionary *modelDic = [NSObject getDic:model containParent:true];
            for (NSString *key in modelDic.allKeys) {
                if ([NUMTOOK([modelDic objectForKey:key]) isEqualToNumber:@(0)]) {
                    [modelDic removeObjectForKey:key];
                }
            }
            [dics addObject:modelDic];
        }
    }
    
    //3. 传给thinkingControl
    [theTC commitInputWithModels:dics algsType:NSStringFromClass(self)];
}

//MARK:===============================================================
//MARK:                     < 视觉算法 >
//MARK:===============================================================

//size
+(CGFloat) sizeWidth:(UIView*)target{
    if (target) return target.width;
    return 0;
}
+(CGFloat) sizeHeight:(UIView*)target{
    if (target) return target.height;
    return 0;
}

//color
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

//radius
+(CGFloat) radius:(UIView*)target{
    if (target) return target.layer.cornerRadius;
    return 0;
}

//speed >> 目前简单粗暴两桢差值 (随后有需要改用微积分)
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

//direction
+(CGFloat) direction:(UIView*)selfView target:(UIView*)target{
    //1. 取距离
    CGPoint distanceP = [self distancePoint:selfView target:target];
    
    //2. 将距离转成角度-PI -> PI (从右至左,上面为-0 -> -3.14 / 从右至左,下面为0 -> 3.14)
    CGFloat rads = atan2f(distanceP.y,distanceP.x);
    
    //3. 将(-PI到PI) 转换成 (0到1)
    float protoParam = (rads / M_PI + 1) / 2;
    
    //4. 将(0到1)转成四舍五入整数(0-8);
    int paramInt = (int)roundf(protoParam * 8.0f);
    
    //5. 如果是8,也是0;
    float result = (paramInt % 8) / 8.0f;
    NSLog(@"视觉目标方向 >> 角度:%f 原始参数:%f 返回参数:%f",rads / M_PI * 180,protoParam,result);
    return result;
}

//direction
+(CGFloat) distance:(UIView*)selfView target:(UIView*)target{
    CGPoint distanceP = [self distancePoint:selfView target:target];
    CGFloat distance = sqrt(powf(distanceP.x, 2) + powf(distanceP.y, 2));
    return distance;
}

//border
+(CGFloat) border:(UIView*)target{
    if (target) return target.layer.borderWidth;
    return 0;
}


//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================
+(CGPoint) distancePoint:(UIView*)selfView target:(UIView*)target{
    if (selfView && target) {
        CGPoint targetPoint = [UIView convertWorldPoint:target];
        CGPoint selfPoint = [UIView convertWorldPoint:selfView];
        CGFloat distanceX = (targetPoint.x - selfPoint.x);
        CGFloat distanceY = (targetPoint.y - selfPoint.y);
        return CGPointMake(distanceX, distanceY);
    }
    return CGPointZero;
}

@end
