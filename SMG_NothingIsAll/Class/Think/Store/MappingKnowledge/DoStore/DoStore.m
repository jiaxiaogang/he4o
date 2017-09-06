//
//  DoStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DoStore.h"
#import "SMG.h"
#import "StoreHeader.h"
#import "SMGHeader.h"
#import "PINCache.h"

@interface DoStore ()

/**
 *  MARK:--------------------分词数组--------------------
 *
 *  结构:
 *      (DIC | Key:itemName Value:str | Key:itemId Value:NSInteger )注:itemId为主键;
 *
 *  元素:
 *      (行为对象,如打,吃等);
 *
 */
@property (strong,nonatomic) NSMutableArray *dataArr;


@end

@implementation DoStore



/**
 *  MARK:--------------------public--------------------
 */
//精确匹配某词
-(NSDictionary*) getSingleItemWithItemName:(NSString*)itemName{
    return [self getSingleItemWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(itemName),@"itemName", nil]];
}

//获取where的最近一条;(精确匹配)
-(NSDictionary*) getSingleItemWithWhere:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        return nil;
    }
    for (NSInteger i = self.dataArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.dataArr[i];
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

-(NSMutableArray*) getItemArrWithWhere:(NSDictionary*)where{
    //数据检查
    if (where == nil || where.count == 0) {
        return self.dataArr;
    }
    NSMutableArray *valArr = nil;
    for (NSInteger i = self.dataArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.dataArr[i];
        BOOL isEqual = true;
        //对比所有value;
        for (NSString *key in where.allKeys) {
            if (![SMGUtils compareItemA:[item objectForKey:key] itemB:[where objectForKey:key]]) {
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

/**
 *  MARK:--------------------addItem--------------------
 */
-(NSDictionary*) addItem:(NSString*)itemName{
    NSDictionary *item = [self createItemWithName:itemName withRemoveLocal:true];
    if (item) {
        [self.dataArr addObject:item];
        [self saveToLocal];
        return item;
    }
    return nil;
}


-(NSMutableArray*) addItemNameArr:(NSArray*)itemNameArr{
    NSMutableArray *valueArr = nil;
    if (ARRISOK(itemNameArr)) {
        valueArr = [[NSMutableArray alloc] init];
        for (NSString *itemName in itemNameArr) {
            NSDictionary *item = [self createItemWithName:itemName withRemoveLocal:true];
            if (item) {
                [self.dataArr addObject:item];
                [valueArr addObject:item];
            }
        }
        [self saveToLocal];
    }
    return valueArr;
}

/**
 *  MARK:--------------------private--------------------
 */
-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [[NSMutableArray alloc] initWithArray:[self getLocalArr]];
    }
    return _dataArr;
}

//硬盘存储;(不常调用,调用耗时)
-(NSArray*) getLocalArr{
    return [[PINCache sharedCache] objectForKey:@"MKStore_Do_DataArr_Key"];
}

-(void) saveToLocal{
    [[PINCache sharedCache] setObject:self.dataArr forKey:@"MKStore_Do_DataArr_Key"];
}

-(NSInteger) createItemId{
    return [self createItemId:1];
}

-(NSInteger) createItemId:(NSInteger)limit{
    limit = MAX(0, limit);
    NSInteger lastId = [[NSUserDefaults standardUserDefaults] integerForKey:@"MKStore_Do_ItemId"];
    [[NSUserDefaults standardUserDefaults] setInteger:lastId + limit forKey:@"MKStore_Do_ItemId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return lastId + limit;
}

-(NSDictionary*) createItemWithName:(NSString*)itemName withRemoveLocal:(BOOL)removeLocal{
    if (!STRISOK(itemName)) {
        return nil;
    }
    //1,找本地重复的
    NSDictionary *localItem = [self getSingleItemWithItemName:itemName];
    //2,remove掉旧的;创建新的;
    if (localItem) {
        if (removeLocal) {
            [self.dataArr removeObject:localItem];
        }
        return localItem;
    }else{
        NSString *itemId = [NSString stringWithFormat:@"%ld",[self createItemId]];
        return [NSDictionary dictionaryWithObjectsAndKeys:itemName,@"itemName",itemId,@"itemId", nil];
    }
}


-(void) clear{
    [self.dataArr removeAllObjects];
    [self saveToLocal];
}













/**
 *  MARK:--------------------创建本地单一的DoModel--------------------
 */
+(DoModel*) createInstanceModel:(NSString*)doType{
    DoModel *model = [DoModel searchSingleWithWhere:[DBUtils sqlWhere_K:@"doType" V:doType] orderBy:nil];
    if (model == nil) {
        model = [[DoModel alloc] init];
        model.doType = doType;
        [DoModel insertToDB:model];
    }
    return model;
}

@end

