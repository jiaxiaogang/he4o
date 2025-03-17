//
//  AIVisionAlgsModelV2.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------V2更新支持多码特征--------------------
 */
@interface AIVisionAlgsModelV2 : NSObject

@property (assign, nonatomic) NSInteger levelNum;//粒度层数

/**
 *  MARK:--------------------色值组（K=x_y位置，元素为InputDotModel）。--------------------
 *  @desc K=x_y 用于表示位置：不一定是平面，也可以是曲面中的xy点位置，比如人体表面。
 *  @desc 建议以中心点为0，有助于更全的视角。
 *  TODO: 饱和度和亮度，可以考虑只保留最多三层27x27格（这样可以节约许多性能，也不太影响视觉表征和识别等）。
 */
@property (strong,nonatomic) NSDictionary *hColors;//色相
@property (strong,nonatomic) NSDictionary *sColors;//饱和度
@property (strong,nonatomic) NSDictionary *bColors;//亮度

@end
