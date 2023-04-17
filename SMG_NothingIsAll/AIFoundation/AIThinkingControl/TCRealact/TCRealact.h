//
//  TCRealact.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------取实战actionFo--------------------
 *  @desc 用于当iCanset太抽象时(含空概念时),向具象取出真实可行的供行为化的解决方案 (;
 */
@interface TCRealact : NSObject

/**
 *  MARK:--------------------懒加载真正跑行为化的actionFo--------------------
 */
+(AIKVPointer*) getRealactFo:(TOFoModel*)foModel;

@end
