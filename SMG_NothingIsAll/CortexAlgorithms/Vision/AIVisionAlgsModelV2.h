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

//size（改由像素量来感知尺寸）。
//@property (assign,nonatomic) NSInteger sizeHeight;

//1. 每一粒度层级的幂，求出在视角中，取哪个xy位置。

//色值组（K=x_y位置，元素为像素DotColorModel）。
@property (strong,nonatomic) NSDictionary *hColors;//色相
@property (strong,nonatomic) NSDictionary *sColors;//饱和度
@property (strong,nonatomic) NSDictionary *bColors;//亮度

//direction（改由像素量来感知距离）。
//@property (assign,nonatomic) NSInteger direction;

//distance（改由像素量来感知距离）。
//@property (assign,nonatomic) NSInteger distance;

//border（用全像素量来分析是否带皮）。
//@property (assign,nonatomic) NSInteger border;

@end
