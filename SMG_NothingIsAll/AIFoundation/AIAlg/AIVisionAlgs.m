//
//  AIVisionAlgs.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/15.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIVisionAlgs.h"

float lastDistance = CGFLOAT_MAX;//以max表示无值;

@implementation AIVisionAlgs

+(void) commitView:(UIView*)selfView targetView:(UIView*)targetView{
    NSLog(@"对小鸟的视觉进行算法处理");
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
    if (target) return target.backgroundColor.red * 255;
    return 0;
}
+(NSInteger) colorGreen:(UIView*)target{
    if (target) return target.backgroundColor.green * 255;
    return 0;
}
+(NSInteger) colorBlue:(UIView*)target{
    if (target) return target.backgroundColor.blue * 255;
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
    if (target && selfView) return target.x - selfView.x;
    return 0;
}
+(CGFloat) originY:(UIView*)selfView target:(UIView*)target{
    if (target && selfView) return target.y - selfView.y;
    return 0;
}


//MARK:===============================================================
//MARK:                     < speed >
//MARK:===============================================================
+(CGFloat) speed:(UIView*)selfView target:(UIView*)target{
    CGFloat result = 0;
    if (target && selfView){
        CGFloat distanceX = (target.x - selfView.x);
        CGFloat distanceY = (target.y - selfView.y);
        CGFloat distance = sqrt(powf(distanceX, 2) + powf(distanceY, 2));
        if (lastDistance != CGFLOAT_MAX) {
            result = distance - lastDistance;
        }
        lastDistance = distance;
    }
    return result;
}

@end
