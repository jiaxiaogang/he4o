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

@interface TextStore ()

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
@property (strong,nonatomic) NSMutableArray *wordArr;


@end

@implementation TextStore






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
    return [[TMCache sharedCache] objectForKey:@"MKStore_Text_WordArr_Key"];
}


/**
 *  MARK:--------------------public--------------------
 */
//精确匹配某词
-(NSDictionary*) getSingleWordWithText:(NSString*)word{
    return [self getSingleWordWithWhere:[NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(word),@"word", nil]];
}

//获取where的最近一条;(精确匹配)
-(NSDictionary*) getSingleWordWithWhere:(NSDictionary*)whereDic{
    //数据检查
    if (whereDic == nil || whereDic.count == 0) {
        return nil;
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

/**
 *  MARK:--------------------给句子智能分词--------------------
 *
 *  (一个句子有可能有多种分法:[[indexPath0,indexPath1],[indexP0]],现在只作一种)
 *
 */
-(NSMutableArray*) getIntelligenceWordArrWithSentence:(NSString*)sentence{
    //1,单字词:了,的,是,啊,呢;
    //2,双字词:牛逼,咬叼;
    //3,多字词:中国人;
    NSMutableArray *mArr = nil;
    sentence = STRTOOK(sentence);
    if (!STRISOK(sentence)) {
        return mArr;
    }
    
    //1,把所有词找出来;
    NSMutableArray *wordArr = [self getWordArrWithSentence:sentence];
    //2,测试连贯性;(最连贯的返回)(参考:笔记p12;)
    if (wordArr) {
        //3,应该找出意思最合理的返回,但目前只返回最通顺的
        //xxx
        //3.1,从前往后
        //3.2,优先长词
        //3.3,遇到非词时,反推;
    }
    
    return mArr;
}

/**
 *  MARK:--------------------从句子中找出所有分词--------------------
 *  注:误区,这种方式将依赖于算法;
 */
-(NSMutableArray*) getWordArrWithSentence:(NSString*)sentence{
    NSMutableArray *mArr = nil;
    sentence = STRTOOK(sentence);
    if (!STRISOK(sentence)) {
        return mArr;
    }
    for (NSInteger loc = 0; loc < sentence.length; loc ++) {
        for (NSInteger len = 1; len < sentence.length - loc; len ++) {
            NSString *checkWord = [sentence substringWithRange:NSMakeRange(loc, len)];
            if ([self getSingleWordWithText:checkWord]) {
                if (mArr == nil) {
                    mArr = [[NSMutableArray alloc] init];
                }
                [mArr addObject:SMGRangeMake(loc, len)];
            }
        }
    }
    return mArr;
}


/**
 *  MARK:--------------------预判词--------------------
 *  参数:
 *      1,limit:取几个
 *      2,havThan:有没达到多少个结果
 *
 *  注:
 *      1,目前仅支持用"一刀两"推出"一刀两断"从前至后预判;
 *      2,词本身不作数 如:"计算" 只能判出"计算机"不能返回"计算";
 */
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
-(NSDictionary*) addWord:(NSString*)word{
    //去重
    if (word) {
        NSString *itemId = [NSString stringWithFormat:@"%ld",[self createItemId]];
        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(word),@"word",itemId,@"itemId", nil];
        [self.wordArr addObject:item];
        [self saveToLocal];
        return item;
    }
    return nil;
}

-(NSMutableArray*) addWordArr:(NSArray*)wordArr{
    //去重
    NSMutableArray *valueArr = nil;
    if (ARRISOK(wordArr)) {
        NSInteger itemId = [self createItemId:wordArr.count];//申请wordArr.count个wordId
        for (NSString *word in wordArr) {
            if (valueArr == nil) valueArr = [[NSMutableArray alloc] init];
            NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(word),@"word",[NSString stringWithFormat:@"%ld",itemId],@"itemId", nil];
            [valueArr addObject:item];
            itemId ++;
        }
        //save
        [self.wordArr addObjectsFromArray:valueArr];
        [self saveToLocal];
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



@end
