//
//  FoodView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@interface FoodView : UIView

@property (assign,nonatomic) FoodStatus status;

//被撞击
-(void) hit;

@end
