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
        return [selfView.superview convertPoint:selfView.center toView:theApp.window];
    }
    return CGPointZero;
}

+(CGRect) convertWorldRect:(UIView*)selfView{
    if(selfView && selfView.superview){
        return [selfView.superview convertRect:selfView.frame toView:theApp.window];
    }
    return CGRectZero;
}


@end
