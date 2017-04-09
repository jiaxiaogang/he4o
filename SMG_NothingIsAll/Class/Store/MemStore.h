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
 *  1,MemStore.memArr是内存kv存储;
 *  2,MemStore的TMCache中有localKV存储;
 */
@interface MemStore : NSObject

@property (strong,nonatomic) NSMutableArray *memArr;  //内存kv存储;(数组中存LanguageStoreModel对象)(习惯记忆,GC会回收不常用的旧数据到localArr)

-(NSArray*) localArr;                                 //硬盘存储;(不常调用,调用耗时)

@end
