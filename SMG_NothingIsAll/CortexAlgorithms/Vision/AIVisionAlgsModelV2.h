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

//色值组（K=x_y位置，元素为InputDotModel）。
@property (strong,nonatomic) NSDictionary *hColors;//色相
@property (strong,nonatomic) NSDictionary *sColors;//饱和度
@property (strong,nonatomic) NSDictionary *bColors;//亮度

@end
