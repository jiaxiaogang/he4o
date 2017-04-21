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
-(NSDictionary*) getSingleWordWithText:(NSString*)text{
    return [self getSingleWordWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(text),@"text", nil]];
}

//获取where的最近一条;(精确匹配)
-(NSDictionary*) getSingleWordWithWhere:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        if (self.wordArr.count > 0) {
            return [self.wordArr lastObject];
        }else{
            return nil;
        }
    }
    for (NSInteger i = self.wordArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.wordArr[i];
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

//给句子分词(一个句子有可能有多种分法:[[indexPath0,indexPath1],[indexP0]],现在只作一种)
+(NSMutableArray*) getIntelligenceWordArrWithSentence:(NSString*)sentence{
    //1,单字词:了,的,是,啊,呢;
    //2,双字词:牛逼,咬叼;
    //3,多字词:中国人;
    return nil;
}

//预判词(limit:取几个 | havThan:有没达到多少个结果)
//注:目前仅支持用"一刀两"推出"一刀两断"从前至后预判;
//注:词本身不作数 如:"计算" 只能判出"计算机"不能返回"计算";
-(void) getInferenceWord:(NSString*)str withLimit:(NSInteger)limit withHavThan:(NSInteger)havThan withOutBlock:(void(^)(NSMutableArray *valueWords,BOOL havThan))outBlock {
    //数据检查
    NSMutableArray *mArr = nil;
    str = STRTOOK(str);
    if (!STRISOK(str) || limit == 0 || self.wordArr == nil) {
        if (outBlock) outBlock(mArr,havThan >= 0);
    }
    //找
    NSInteger findCount = 0;
    for (NSInteger i = self.wordArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.wordArr[i];
        NSString *itemText = [item objectForKey:@"text"];
        if (itemText && itemText.length > str.length) {
            if ([str isEqualToString:[itemText substringToIndex:str.length]]) {
                if (mArr == nil) {
                    mArr = [[NSMutableArray alloc] init];
                }
                //收集;
                if (mArr.count < limit) {
                    [mArr addObject:itemText];
                }
                //计数;
                findCount ++;
                //收集完毕;
                if (findCount >= havThan && mArr.count >= limit) {
                    break;
                }
            }
        }
    }
    //送出
    if (outBlock) outBlock(mArr,findCount >= havThan);
}

-(NSMutableArray*) getWordArrWithWhere:(NSDictionary*)where{
    //数据检查
    if (where == nil || where.count == 0) {
        return self.wordArr;
    }
    NSMutableArray *valArr = nil;
    for (NSInteger i = self.wordArr.count - 1; i >= 0; i--) {
        NSDictionary *item = self.wordArr[i];
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
 *  MARK:--------------------add--------------------
 */
-(void) addWord:(NSDictionary*)word{
    if (word) {
        [self.wordArr addObject:word];
        [self saveToLocal];
    }
}


-(void) saveToLocal{
    [[TMCache sharedCache] setObject:self.wordArr forKey:@"Language_WordArr_Key"];
}



@end
