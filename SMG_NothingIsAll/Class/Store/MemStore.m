//
//  MemStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MemStore.h"
#import "TMCache.h"
#import "SMGHeader.h"


@interface MemStore ()

/**
 *  MARK:--------------------记忆流--------------------
 *
 *  结构:
 *      (DIC | Key:word Value:str | Key:wordId Value:NSInteger )注:wordId为主键;
 *
 *  元素:
 *      (有单字词:如:你我他的是啊)(有多字词:如:你好,人民,苹果)
 *
 *  考虑:
 *      1,功能:随后添加分词使用频率;使其更正确的工作;
 *
 */
@property (strong,nonatomic) NSMutableArray *memArr;

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
    if (mem) {
        NSInteger memIndex = [self.memArr indexOfObject:mem];
        if (memIndex >= 0 && memIndex < self.memArr.count - 1) {
            return self.memArr[memIndex + 1];
        }
    }
    return nil;
}

-(NSDictionary*) getSingleMemoryWithWhereDic:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        return [self getLastMemory];
    }
    for (NSInteger i = self.memArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.memArr[i];
        BOOL isEqual = true;
        //对比所有value;
        for (NSString *key in whereDic.allKeys) {
            if (![SMGUtils compareItemA:[item objectForKey:key] itemB:[whereDic objectForKey:key]]) {
                isEqual = false;
            }
        }
        //都一样,则返回;
        if (isEqual) {
            return item;
        }
    }
    return nil;
}

-(NSMutableArray*) getMemoryWithWhereDic:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        return self.memArr;
    }
    NSMutableArray *valArr = nil;
    for (NSInteger i = self.memArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.memArr[i];
        BOOL isEqual = true;
        //对比所有value;
        for (NSString *key in whereDic.allKeys) {
            if (![SMGUtils compareItemA:[item objectForKey:key] itemB:[whereDic objectForKey:key]]) {
                isEqual = false;
            }
        }
        //都一样,则收集到valArr;
        if (isEqual) {
            if (valArr == nil) {
                valArr = [[NSMutableArray alloc] init];
            }
            [valArr addObject:item];
        }
    }
    return valArr;
}

//获取where的最近一条;(模糊匹配)
-(NSDictionary*) getSingleMemoryContainsWhereDic:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        return [self getLastMemory];
    }
    for (NSInteger i = self.memArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.memArr[i];
        //是否item包含whereDic
        if ([SMGUtils compareItemA:item containsItemB:whereDic]) {
            return item;
        }
    }
    return nil;
}

//获取where的所有条;(模糊匹配)
-(NSMutableArray*) getMemoryContainsWhereDic:(NSDictionary*)whereDic limit:(NSInteger)limit{
    NSMutableArray *valArr = nil;
    for (NSInteger i = self.memArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.memArr[i];
        //是否item包含whereDic
        if ([SMGUtils compareItemA:item containsItemB:whereDic]) {
            if (valArr == nil) {
                valArr = [[NSMutableArray alloc] init];
            }
            [valArr addObject:item];
            if (valArr.count >= limit) {
                return valArr;
            }
        }
    }
    return valArr;
}


-(void) addMemory:(NSDictionary*)mem{
    if (mem) {
        [self.memArr addObject:mem];
        [self saveToLocal];
    }
}

-(void) addMemory:(NSDictionary*)mem insertFrontByMem:(NSDictionary*)byMem{
    if (mem && byMem) {
        NSInteger byMemIndex = [self.memArr indexOfObject:byMem];
        if (byMemIndex > 0) {
            [self.memArr insertObject:mem atIndex:byMemIndex - 1];
            [self saveToLocal];
        }
    }
}

-(void) addMemory:(NSDictionary*)mem insertBackByMem:(NSDictionary*)byMem{
    if (mem && byMem) {
        NSInteger byMemIndex = [self.memArr indexOfObject:byMem];
        if (byMemIndex > 0) {
            if (byMemIndex < self.memArr.count - 1) {
                [self.memArr insertObject:mem atIndex:byMemIndex + 1];
            }else{
                [self.memArr addObject:mem];
            }
            [self saveToLocal];
        }
    }
}

-(void) saveToLocal{
    [[TMCache sharedCache] setObject:self.memArr forKey:@"MemStore_LocalArr_Key"];
}

@end
