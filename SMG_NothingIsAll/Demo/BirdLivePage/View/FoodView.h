//
//  FoodView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define cCanEatMainNum @"s"
#define cCantEatMainNum @"1"

/**
 *  MARK:--------------------FoodStatus--------------------
 */
typedef NS_ENUM(NSInteger, FoodStatus) {
    FoodStatus_Border = 0,    //有皮
    FoodStatus_Eat = 1,       //可吃
    FoodStatus_Remove = 2,    //压烂
};


/**
 *  MARK:--------------------坚果类--------------------
 *  1. 汽车压一次消皮,压两次报废;
 */
@interface FoodView : HEView

@property (assign,nonatomic) FoodStatus status;

@property (strong, nonatomic) NSString *imgName;
@property (strong, nonatomic) UIImageView *imgView;//当前坚果是几号（用于测视觉）。

-(void) setData:(NSString*)mainNum;

//被撞击
-(void) hit;
-(BOOL) canEat;

@end
