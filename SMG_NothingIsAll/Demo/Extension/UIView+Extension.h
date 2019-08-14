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


@end


