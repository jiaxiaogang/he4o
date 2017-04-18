//
//  FeelImgModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FeelModel.h"


/**
 *  MARK:--------------------Input_视觉图像感觉化数据--------------------
 *  基于双摄像头的立体计算机视觉;
 *
 *  1,抠图
 *  2,人脸,表情
 *  3,肢体动作
 *
 *
 */
@interface FeelImgModel : FeelModel

@property (strong,nonatomic) UIImage *img;                      //图片
@property (assign, nonatomic) CGRect frame;                     //坐标及大小

@end


//1,需要使用双摄像头来构建3d图像立体;
//2,需要实现3d抠图;将目标的抠出;(考虑kinnet)
//3,先使用假数据,来定义数据结构和接口;
//4,等写好基于3d的计算机视觉系统后,再接入进来;



static NSString *FeelImgModelAttributesKey_Line     = @"line";  //抽象线的path
static NSString *FeelImgModelAttributesKey_Area     = @"area";  //抽象面的外形
