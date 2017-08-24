//
//  AIMindValueStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIMindValueStore : AIStoreBase

/**
 *  MARK:--------------------存储MindValue--------------------
 *  //默认不存至意识流(参考N4P11)
 */
+(void) insert:(AIObject *)data;

@end
