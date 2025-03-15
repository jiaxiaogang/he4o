//
//  InputDotModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单像素模型，用于表征xy轴中某像素点值的感官信息（如视觉图像，的色值，亮度）--------------------
 *  @比如，表示色值时，可以用H色相0-360度表示。
 */
@interface InputDotModel : NSObject

@property (assign, nonatomic) int level;//粒度级别（越大越细，越小越粗）
@property (strong, nonatomic) NSDictionary *subInputDotModels;//递归结构，单父多子，多粒度层嵌套。

/**
 *  MARK:--------------------值：表示色相，饱和度，亮度，压力等--------------------
 */
@property (assign, nonatomic) int v;//值

/**
 *  MARK:--------------------是否循环值：循环值的首尾相接（如色相0到360）。--------------------
 */
-(BOOL) isLoop;//是否循环值
@property (assign, nonatomic) int roopMin;//循环中的最小值
@property (assign, nonatomic) int roopMax;//循环中的最大值

@end
