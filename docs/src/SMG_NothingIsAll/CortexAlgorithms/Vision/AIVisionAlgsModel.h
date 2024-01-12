//
//  AIVisionAlgsModel.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------视觉算法结果模型--------------------
 *  1. 用于输入到ThinkingControl;
 *  @version
 *      2021.09.14: 废弃速度,因为HE视觉是离散的,速度不重要 (参考24017-问题1);
 *      2022.06.04: 加上X距,废弃posX和方向 (参考26196-方案3);
 *      2022.06.05: 回退26196-方案3 (废弃X距,打开posX和方向) (参考26196-尝试1);
 *      2022.06.05: 太近时方向不稳定,所以废弃,改成X距 (参考26196-尝试3-结果);
 */
@interface AIVisionAlgsModel : NSObject

//size
//@property (assign,nonatomic) NSInteger sizeWidth;
@property (assign,nonatomic) NSInteger sizeHeight;

//color
//@property (assign,nonatomic) NSInteger colorRed;
//@property (assign,nonatomic) NSInteger colorGreen;
//@property (assign,nonatomic) NSInteger colorBlue;

//radius
//@property (assign,nonatomic) NSInteger radius;

//speed
//@property (assign,nonatomic) NSInteger speed;

//direction
@property (assign,nonatomic) NSInteger direction;

//distance
//20230308: 去掉距离 (因为与Y距X距重复);
//20230313: 用距离替代XY距 (参考28174-todo3);
@property (assign,nonatomic) NSInteger distance;
//@property (assign,nonatomic) NSInteger distanceX;
//@property (assign,nonatomic) NSInteger distanceY;

//border
@property (assign,nonatomic) NSInteger border;

//20190723: originX和originY由direction和distance替代;
//20200317: 二测训练时,再打开,与distance共存,并更名为posX/Y;
//20230308: 客观特征全去掉 (参考28161-方案5);
//@property (assign,nonatomic) NSInteger posX;
//@property (assign,nonatomic) NSInteger posY;

@end
