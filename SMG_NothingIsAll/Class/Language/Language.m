//
//  LanguageUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Language.h"
#import "SMG.h"
#import "StoreHeader.h"
#import "SMGHeader.h"
#import "LanguageHeader.h"
#import "TMCache.h"

@interface Language ()

@property (strong,nonatomic) NSMutableArray *wordArr;       //分词(DIC | Key:word Value:str | Key:MKObjId Value:NSInteger )

@end

@implementation Language



/**
 *  MARK:--------------------语言输出能力--------------------
 */
-(NSString*) outputTextWithRequestText:(NSString*)requestText withStoreModel:(id)storeModel{
    
    //1,有记忆根据mind值排序回复;(找到习惯系统中的最佳回答)
    //这里修改为到'逻辑记忆'中取最佳回答;
    //    if (storeModel && storeModel.logArr && storeModel.logArr.count) {
    //        NSArray *sortArr = [storeModel.logArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    //            return ((StoreLogModel_Text*)obj1).powerValue < ((StoreLogModel_Text*)obj2).powerValue;
    //        }];
    //        StoreLogModel_Text *logModel = sortArr[0];
    //        if (logModel.powerValue > 0 ) {
    //            return logModel.text;
    //        }
    //    }
    //2,无记忆则根据;模糊搜索记忆
    //NSArray *arr = [[SMG sharedInstance].store searchMemStoreContainerText:STRTOOK(requestText)];
    //3,找到模糊匹配时,找匹配项
    //    if (arr) {
    //        for (StoreModel_Text *storeModel in arr) {
    //            if(storeModel.logArr){
    //                for (StoreLogModel_Text *logModel in storeModel.logArr) {
    //                    if (logModel.powerValue > 2) {
    //                        return logModel.text;
    //                    }
    //                }
    //            }
    //        }
    //    }
    //4,模糊无时,判断交流欲望(心情不好时,不回答)
    if ([SMG sharedInstance].mind.sadHappyValue < 0) {
        return @"(▭-▭)✧";//淡定;
    }
    //5,开心时,随机返回点东西;//xxx明天写;
    
    //在requestText中找分词;自己大脑中有分词的情况下;
    if (requestText) {
        //xxx需要整个理解系统的工作;不然这里跑不通;
    }
    //假如无分词时,文字大于三字;则不回答;
    //小于三字;则尝试回答;
    return nil;
}


/**
 *  MARK:--------------------用于分析语言输入,并且找出规律词和图谱词并返回--------------------
 *
 */
-(NSArray*) inputTextWithRequestText:(NSString*)requestText{
    return nil;
}



















/**
 *  MARK:--------------------private--------------------
 */
-(NSMutableArray *)wordArr{
    if (_wordArr == nil) {
        _wordArr = [[NSMutableArray alloc] initWithArray:[self getLocalArr]];
    }
    return _wordArr;
}

//硬盘存储;(不常调用,调用耗时)
-(NSArray*) getLocalArr{
    return [[TMCache sharedCache] objectForKey:@"Language_WordArr_Key"];
}


/**
 *  MARK:--------------------public--------------------
 */
//精确匹配某词

//给句子分词(一个句子有可能有多种分法:[[indexPath0,indexPath1],[indexP0]],现在只作一种)
+(NSMutableArray*) getIntelligenceWordArrWithSentence:(NSString*)sentence{
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
    [[TMCache sharedCache] setObject:self.wordArr forKey:@"Language_WordArr_Key"];
}



@end
