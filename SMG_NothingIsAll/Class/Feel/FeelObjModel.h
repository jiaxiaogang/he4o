//
//  FeelObjModel.h
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
 *  基于双摄像头的立体计算机视觉;(ImgModel表示的是RealObj实物)
 *
 *  1,人脸,表情
 *  2,肢体动作
 *
 *  1,我想通过"视觉目标"的属性(3d模型,颜色,大小等)来确定唯一性;
 *  2,我想实现"视觉目标"的抠图;
 *  3,我想实现确定唯一性后,优先从MappingKnowledge取本地数据(优化性能,数据也更可靠)
 *  4,我想通过非数码摄像头实现(这条只是设想)
 *
 *
 */
@interface FeelObjModel : FeelModel

@property (strong,nonatomic) NSString *name;                    //实物名字
@property (strong,nonatomic) UIImage *img;                      //图片
@property (assign, nonatomic) CGRect frame;                     //坐标及大小

@end


//1,需要使用双摄像头来构建3d图像立体;
//2,需要实现3d抠图;将目标的抠出;(考虑kinnet)
//3,先使用假数据,来定义数据结构和接口;
//4,等写好基于3d的计算机视觉系统后,再接入进来;



static NSString *FeelImgModelAttributesKey_Line     = @"line";  //抽象线的path
static NSString *FeelImgModelAttributesKey_Area     = @"area";  //抽象面的外形
