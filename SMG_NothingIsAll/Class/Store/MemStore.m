//
//  MemStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MemStore.h"
#import "TMCache.h"


@interface MemStore ()

@property (strong,nonatomic) NSMutableArray *memArr;  //内存kv存储;(数组中存StoreModel_Text对象)(习惯记忆,GC会回收不常用的旧数据到localArr)

@end


@implementation MemStore


/**
 *  MARK:--------------------private--------------------
 */
-(NSMutableArray *)memArr{
    if (_memArr == nil) {
        _memArr = [[NSMutableArray alloc] initWithArray:[self getLocalArr]];
    }
    return _memArr;
}



//硬盘存储;(不常调用,调用耗时)
-(NSArray*) getLocalArr{
    return [[TMCache sharedCache] objectForKey:@"MemStore_LocalArr_Key"];
}


/**
 *  MARK:--------------------public--------------------
 */
-(NSDictionary*) getLastMemory{
    return [self.memArr lastObject];
}

-(NSDictionary*) getPreviousMemory:(NSDictionary*)mem{
    if (mem) {
        NSInteger memIndex = [self.memArr indexOfObject:mem];
        if (memIndex > 0) {
            return self.memArr[memIndex - 1];
        }
    }
    return nil;
}

-(NSDictionary*) getNextMemory:(NSDictionary*)mem{
    
}


-(void) addMemory:(NSDictionary*)mem{
    
}

-(void) addMemoryToFront:(NSDictionary*)mem{
    
}

-(void) addMemoryToBack:(NSDictionary*)mem{
    
}

-(void) saveToLocal{
    [[TMCache sharedCache] setObject:self.memArr forKey:@"MemStore_LocalArr_Key"];
}

@end
