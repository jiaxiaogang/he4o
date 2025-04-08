//
//  FoodView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

//图库图片的前辍
#define cCanEatMainNum @"0"
#define cCantEatMainNum @"1"

//图库文件夹名称 @“ProtoMnistImages”=Mnist数字库 @"ProtoSImages"=自己拍的鼠标照片，只有12张。
#define cProtoImageFolder @"ProtoMnistImages"
#define cTestImageFolder @"TestMnistImages"

//图库图片数，比如后辍1-17。
#define cProtoImageCount 17

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
