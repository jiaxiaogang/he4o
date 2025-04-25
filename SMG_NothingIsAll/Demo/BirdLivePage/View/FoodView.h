//
//  FoodView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

//图库图片的前辍
#define cCanEatMainNum @[@"鼠",@"0",@"杯",@"柄",@"球",@"饮",@"签"]
#define cCantEatMainNum @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"]

//图库图片数，比如后辍1-17。
#define cProtoImageCount 100
#define cTestImageCount 1

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

-(void) setData:(NSString*)mainNum subNum:(NSInteger)subNum forTest:(BOOL)forTest;

//被撞击
-(void) hit;
-(BOOL) canEat;

@end
