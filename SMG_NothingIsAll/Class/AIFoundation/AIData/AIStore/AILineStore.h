//
//  AILineStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStoreBase.h"

@interface AILineStore : AIStoreBase

+(AILine*) searchSinglePointers:(NSArray*)pointers;
+(NSMutableArray*) searchPointer:(AIPointer*)pointer count:(NSInteger)count;
+(NSMutableArray*) searchPointer:(AIPointer*)pointer energy:(NSInteger)energy;//根据"能量"以"pointer"为中心搜索;

+(void) insert:(AIObject *)data;

@end
