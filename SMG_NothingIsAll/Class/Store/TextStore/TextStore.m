//
//  Text.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "TextStore.h"
#import "SMG.h"
#import "StoreHeader.h"
#import "SMGHeader.h"
#import "TMCache.h"
#import "TextModel.h"


/**
 *  MARK:--------------------分词数组--------------------
 *
 *  结构:
 *      (DIC | Key:word Value:str | Key:itemId Value:NSInteger | Key:doId Value:NSInteger | Key:objId Value:NSInteger )注:itemId为主键;
 *
 *  元素:
 *      (有单字词:如:你我他的是啊)(有多字词:如:你好,人民,苹果)
 *
 *  考虑:
 *      1,功能:随后添加分词使用频率;使其更正确的工作;
 *
 */
@interface TextStore ()


@end

@implementation TextStore




















/**
 *  MARK:--------------------private--------------------
 */
-(NSMutableArray *)wordArr{
    return [TextModel searchWithWhere:nil];
}


/**
 *  MARK:--------------------public--------------------
 */
+(TextModel*) getSingleWordWithText:(NSString*)text{
    return [TextModel searchSingleWithWhere:[DBUtils sqlWhere_K:@"text" V:STRTOOK(text)] orderBy:nil];
}
+(TextModel*) getSingleWordWithItemId:(NSInteger)itemId{
    return [TextModel searchSingleWithWhere:[DBUtils sqlWhere_RowId:itemId] orderBy:nil];
}
+(TextModel*) getSingleWordWithObjId:(NSInteger)objId{
    return [TextModel searchSingleWithWhere:[DBUtils sqlWhere_K:@"objId" V:@(objId)] orderBy:nil];
}
+(TextModel*) getSingleWordWithDoId:(NSInteger)doId{
    return [TextModel searchSingleWithWhere:[DBUtils sqlWhere_K:@"doId" V:@(doId)] orderBy:nil];
}


+(NSMutableArray*) getWordArrWithText:(NSString*)text{
    return [TextModel searchWithWhere:[DBUtils sqlWhere_K:@"text" V:STRTOOK(text)]];
}
+(NSMutableArray*) getWordArrWithObjId:(NSInteger)objId{
    return [TextModel searchWithWhere:[DBUtils sqlWhere_K:@"objId" V:@(objId)]];
}
+(NSMutableArray*) getWordArrWithDoId:(NSInteger)doId{
    return [TextModel searchWithWhere:[DBUtils sqlWhere_K:@"doId" V:@(doId)]];
}
+(NSMutableArray*) getWordArr{
    return [TextModel searchWithWhere:nil];
}




/**
 *  MARK:--------------------add--------------------
 */
-(NSDictionary*) addWord:(NSString*)word withObjId:(NSString*)objId withDoId:(NSString*)doId{
    NSLog(@"保存Word分词:%@__objId:%@__doId:%@",word,objId,doId);
    if (!STRISOK(word)) {
        return nil;
    }
    NSMutableDictionary *newItem = [[NSMutableDictionary alloc] init];
    //1,找本地重复的
    NSDictionary *localItem = [TextStore getSingleWordWithText:word];
    //2,word,itemId
    if (localItem) {
        [newItem setDictionary:localItem];
        [self.wordArr removeObject:localItem];
    }else{
        NSString *itemId = [NSString stringWithFormat:@"%ld",[self createItemId]];
        [newItem setObject:word forKey:@"word"];
        [newItem setObject:itemId forKey:@"itemId"];
    }
    //3,objId,doId
    if (STRISOK(objId)) [newItem setObject:objId forKey:@"objId"];
    if (STRISOK(doId)) [newItem setObject:doId forKey:@"doId"];
    //4,存新 & 返回;
    [self.wordArr addObject:newItem];
    [self saveToLocal];
    return newItem;
}
-(TextModel*) addWord:(NSString*)text{
    TextModel *model = [[TextModel alloc] init];
    model.text = STRTOOK(text);
    [TextModel insertToDB:model];
    return model;
}

-(NSMutableArray*) addWordArr:(NSArray*)wordArr{
    NSMutableArray *valueArr = nil;
    if (ARRISOK(wordArr)) {
        valueArr = [[NSMutableArray alloc] init];
        for (NSString *word in wordArr) {
            [valueArr addObject:[self addWord:word]];
        }
    }
    return valueArr;
}


/**
 *  MARK:--------------------private--------------------
 */
-(void) saveToLocal{
    [[TMCache sharedCache] setObject:self.wordArr forKey:@"MKStore_Text_WordArr_Key"];
}

-(NSInteger) createItemId{
    return [self createItemId:1];
}

-(NSInteger) createItemId:(NSInteger)limit{
    limit = MAX(0, limit);
    NSInteger lastId = [[NSUserDefaults standardUserDefaults] integerForKey:@"MKStore_Text_WordId"];
    [[NSUserDefaults standardUserDefaults] setInteger:lastId + limit forKey:@"MKStore_Text_WordId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return lastId + limit;
}

-(void) clear{
    [self.wordArr removeAllObjects];
    [self saveToLocal];
}

@end







////获取where的最近一条;(精确匹配)
//-(NSDictionary*) getSingleWordWithWhere:(NSDictionary*)whereDic{
//    //数据检查
//    if (whereDic == nil || whereDic.count == 0) {
//        return nil;
//    }
//    for (NSInteger i = self.wordArr.count - 1; i >= 0; i--) {
//        NSDictionary *item = self.wordArr[i];
//        BOOL isEqual = true;
//        //对比所有value;
//        for (NSString *key in whereDic.allKeys) {
//            if (![SMGUtils compareItemA:[item objectForKey:key] itemB:[whereDic objectForKey:key]]) {
//                isEqual = false;
//            }
//        }
//        //都一样,则返回;
//        if (isEqual) {
//            return item;
//        }
//    }
//    return nil;
//}


//获取多条
//-(NSMutableArray*) getWordArrWithWhere:(NSDictionary*)where{
//    //数据检查
//    if (where == nil || where.count == 0) {
//        return self.wordArr;
//    }
//    NSMutableArray *valArr = nil;
//    for (NSInteger i = self.wordArr.count - 1; i >= 0; i--) {
//        NSDictionary *item = self.wordArr[i];
//        BOOL isEqual = true;
//        //对比所有value;
//        for (NSString *key in where.allKeys) {
//            if (![SMGUtils compareItemA:[item objectForKey:key] itemB:[where objectForKey:key]]) {
//                isEqual = false;
//            }
//        }
//        //都一样,则收集到valArr;
//        if (isEqual) {
//            if (valArr == nil) {
//                valArr = [[NSMutableArray alloc] init];
//            }
//            [valArr addObject:item];
//        }
//    }
//    return valArr;
//}
