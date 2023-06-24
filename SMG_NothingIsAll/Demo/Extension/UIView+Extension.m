//
//  UIView+Extension.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/8.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

//MARK:===============================================================
//MARK:                     < frame >
//MARK:===============================================================
- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

//MARK:===============================================================
//MARK:                     < show (一般用于动画中,取真实显示数据) >
//MARK:===============================================================
- (CGFloat)showX {
    return self.showOrigin.x;
}

- (CGFloat)showY {
    return self.showOrigin.y;
}

- (CGFloat)showW {
    return self.showSize.width;
}

- (CGFloat)showH {
    return self.showSize.height;
}

- (CGRect)showFrame {
    if (ARRISOK(self.layer.animationKeys)) {
        return self.layer.presentationLayer.frame;
    }
    return self.frame;
}

- (CGPoint) showOrigin{
    return self.showFrame.origin;
}

-(CGSize) showSize{
    return self.showFrame.size;
}

- (CGFloat)showMinX {
    return self.showX;
}

- (CGFloat)showMinY {
    return self.showY;
}

- (CGFloat)showMaxX {
    return self.showX + self.showW;
}

- (CGFloat)showMaxY {
    return self.showY + self.showH;
}

- (CGFloat)showCenX {
    return self.showX + self.showW * 0.5f;
}

- (CGFloat)showCenY {
    return self.showY + self.showH * 0.5f;
}

//MARK:===============================================================
//MARK:                     < subView >
//MARK:===============================================================
-(NSMutableArray*) subViews_AllDeep{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [self collectSubViews:arr withClass:[UIView class]];
    return arr;
}
-(NSMutableArray*) subViews_AllDeepWithClass:(Class)aClass{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [self collectSubViews:arr withClass:aClass];
    return arr;
}
-(void) collectSubViews:(NSMutableArray*)arr withClass:(Class)aClass{
    if (arr != nil && aClass != nil){
        if ([self isKindOfClass:aClass]) {
            [arr addObject:self];
        }
        if(self.subviews != nil){
            for (UIView *childView in self.subviews) {
                [childView collectSubViews:arr withClass:aClass];
            }
        }
    }
}

-(NSMutableArray*) subViews_AllDeepWithRect:(CGRect)rect{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    CGRect sRect = [UIView convertWorldRect:self];
    if (CGRectGetMinX(sRect) >= CGRectGetMinX(rect) &&
        CGRectGetMinY(sRect) >= CGRectGetMinY(rect) &&
        CGRectGetMaxX(sRect) <= CGRectGetMaxX(rect) &&
        CGRectGetMaxY(sRect) <= CGRectGetMaxY(rect)) {
        [arr addObject:self];
    }
    if(self.subviews != nil){
        for (UIView *childView in self.subviews) {
            [arr addObjectsFromArray:[childView subViews_AllDeepWithRect:rect]];
        }
    }
    return arr;
}

-(void)removeAllSubviews {
    while (self.subviews.count) {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

//MARK:===============================================================
//MARK:                     < superView >
//MARK:===============================================================
-(NSMutableArray*) superViews_AllDeepWithClass:(Class)aClass{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    UIView *curView = self;
    while (curView.superview) {
        if ([curView.superview isKindOfClass:aClass]) {
            [arr addObject:curView.superview];
        }
        curView = curView.superview;
    }
    return arr;
}

//MARK:===============================================================
//MARK:                     < convert坐标 >
//MARK:===============================================================

/**
 *  MARK:--------------------转换世界坐标--------------------
 *  @result 世界坐标 : NotNull
 */
+(CGPoint) convertWorldPoint:(UIView*)selfView{
    if(selfView && selfView.superview){
        CGRect rect = [self convertWorldRect:selfView];
        return CGPointMake(rect.origin.x + selfView.width / 2.0f, rect.origin.y + selfView.height / 2.0f);
    }
    return CGPointZero;
}

/**
 *  MARK:--------------------转换世界rect--------------------
 *  @version
 *      2021.09.07: 动画中的frame不准确,改为从layer.presentationLayer取才准确;
 */
+(CGRect) convertWorldRect:(UIView*)selfView{
    if(selfView && selfView.superview){
        return [selfView.superview convertRect:selfView.showFrame toView:theApp.window];
    }
    return CGRectZero;
}

//MARK:===============================================================
//MARK:                     < distance >
//MARK:===============================================================
+(CGFloat) distance:(UIView*)selfView target:(UIView*)target{
    return [self convertPoint2DP:[self distancePoint:selfView target:target]];
}

+(CGPoint) distancePoint:(UIView*)selfView target:(UIView*)target{
    if (selfView && target) {
        return [self distance4Point:[UIView convertWorldPoint:selfView] pointB:[UIView convertWorldPoint:target]];
    }
    return CGPointZero;
}

+(CGFloat) distance4DP:(CGPoint)pointA pointB:(CGPoint)pointB {
    return [self convertPoint2DP:[self distance4Point:pointA pointB:pointB]];
}

+(CGPoint) distance4Point:(CGPoint)pointA pointB:(CGPoint)pointB {
    CGFloat distanceX = (pointB.x - pointA.x);
    CGFloat distanceY = (pointB.y - pointA.y);
    return CGPointMake(distanceX, distanceY);
}

//将point距离转成dp距离
+(CGFloat) convertPoint2DP:(CGPoint)p {
    CGFloat disFloat = sqrt(powf(p.x, 2) + powf(p.y, 2));
    CGFloat distance = disFloat / [UIScreen mainScreen].scale;
    return distance;
}

@end
