//
//  UnorderItemModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/3.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------无序列表item模型--------------------
 */
@interface UnorderItemModel : NSObject

@property (assign, nonatomic) int tabNum;//缩进数
@property (strong, nonatomic) id data;   //本行数据

@end
