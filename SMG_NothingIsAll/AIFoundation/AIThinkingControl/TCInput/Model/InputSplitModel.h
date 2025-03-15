//
//  InputSplitModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------粒度模型--------------------
 */
@interface InputSplitModel : NSObject

@property (assign, nonatomic) int level;//粒度级别（越大越细，越小越粗）。

@end
