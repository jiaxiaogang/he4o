//
//  TOModelVisionUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/3.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出短时可视化工具类--------------------
 */
@class TOModelBase;
@interface TOModelVisionUtil : NSObject

/**
 *  MARK:--------------------从当前向所有分支,转为无序列表模型数组--------------------
 */
+(NSMutableArray*) convertCur2Sub2UnorderModels:(TOModelBase*)curModel;

/**
 *  MARK:--------------------获取无序列表的前缀符号--------------------
 */
+(NSString*) getUnorderPrefix:(int)tabNum;

@end
