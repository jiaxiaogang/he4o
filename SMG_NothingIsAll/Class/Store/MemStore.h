//
//  MemStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------记忆存储--------------------
 *  1,MemStore.dic是内存kv存储;
 *  2,MemStore的TMCache中有localKV存储;
 */
@interface MemStore : NSObject

+(id) shareInstance;
@property (strong,nonatomic) NSMutableDictionary *dic;  //内存kv存储;

@end
