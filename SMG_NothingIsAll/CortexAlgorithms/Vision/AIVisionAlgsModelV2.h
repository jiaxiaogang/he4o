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
@property (assign, nonatomic) NSInteger whSize;//宽高点数

/**
 *  MARK:--------------------色值组（K=x_y位置，元素为InputDotModel）。--------------------
 *  @desc K=x_y 用于表示位置：不一定是平面，也可以是曲面中的xy点位置，比如人体表面。
 *  @desc 建议以中心点为0，有助于更全的视角。
 *  TODO: 饱和度和亮度，可以考虑只保留最多三层27x27格（这样可以节约许多性能，也不太影响视觉表征和识别等）。
 */
@property (strong,nonatomic) NSDictionary *hColors;//色相
@property (strong,nonatomic) NSDictionary *sColors;//饱和度
@property (strong,nonatomic) NSDictionary *bColors;//亮度

//TODO: 此处随后支持一下，把值域传到内核中，在稀疏码装箱时，自动处理精度（一般留1/1000的精度足够用）。
//@property (assign, nonatomic) CGFloat hColorsSpan;//色相取值范围大小（传1.0，用于内核处理稀疏码精度）。
//@property (assign, nonatomic) CGFloat sColorsSpan;//饱和度取值范围大小（传1.0，用于内核处理稀疏码精度）。
//@property (assign, nonatomic) CGFloat bColorsSpan;//亮度取值范围大小（传1.0，用于内核处理稀疏码精度）。

@end
