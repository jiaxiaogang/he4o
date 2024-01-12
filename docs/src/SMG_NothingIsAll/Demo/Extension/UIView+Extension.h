//
//  UIView+Extension.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/8.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

//MARK:===============================================================
//MARK:                     < frame >
//MARK:===============================================================
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

//MARK:===============================================================
//MARK:                     < show (一般用于动画中,取真实显示数据) >
//MARK:===============================================================
@property (nonatomic,readonly) CGFloat showX;
@property (nonatomic,readonly) CGFloat showY;
@property (nonatomic,readonly) CGFloat showW;
@property (nonatomic,readonly) CGFloat showH;
@property (nonatomic,readonly) CGRect showFrame;
@property (nonatomic,readonly) CGPoint showOrigin;
@property (nonatomic,readonly) CGSize showSize;

@property (nonatomic,readonly) CGFloat showMinX;
@property (nonatomic,readonly) CGFloat showMinY;
@property (nonatomic,readonly) CGFloat showMaxX;
@property (nonatomic,readonly) CGFloat showMaxY;

- (CGFloat)showCenX;
- (CGFloat)showCenY;


//MARK:===============================================================
//MARK:                     < subView >
//MARK:===============================================================

/**
 *  MARK:--------------------返回指定subViews--------------------
 *  @result : notnull
 */
-(NSMutableArray*) subViews_AllDeep;
-(NSMutableArray*) subViews_AllDeepWithClass:(Class)aClass;
-(NSMutableArray*) subViews_AllDeepWithRect:(CGRect)rect;

-(void)removeAllSubviews;


//MARK:===============================================================
//MARK:                     < superView >
//MARK:===============================================================
-(NSMutableArray*) superViews_AllDeepWithClass:(Class)aClass;


//MARK:===============================================================
//MARK:                     < convert坐标 >
//MARK:===============================================================

/**
 *  MARK:--------------------转换世界坐标--------------------
 *  @result 世界坐标 : NotNull
 */
+(CGPoint) convertWorldPoint:(UIView*)selfView;
+(CGRect) convertWorldRect:(UIView*)selfView;


//MARK:===============================================================
//MARK:                     < distance >
//MARK:===============================================================

//view距离
+(CGFloat) distance:(UIView*)selfView target:(UIView*)target;
+(CGPoint) distancePoint:(UIView*)selfView target:(UIView*)target;
//点距
+(CGFloat) distance4DP:(CGPoint)pointA pointB:(CGPoint)pointB;
+(CGPoint) distance4Point:(CGPoint)pointA pointB:(CGPoint)pointB;
@end


