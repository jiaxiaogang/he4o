//
//  UnderstandUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "UnderstandUtils.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "FeelHeader.h"

@implementation UnderstandUtils




/**
 *  MARK:--------------------从text中找出生分词和已有分词--------------------
 */
+(void) getWordArrAtText:(NSString*)text outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr))outBlock{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    if (!STRISOK(text)) {
        if (outBlock) {
            outBlock(nil,nil);
        }
        return;
    }
    text = STRTOOK(text);
    NSMutableArray *oldArr = [[NSMutableArray alloc] init];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    ////2,循环找text中的新词
    //for (int i = 0; i < text.length - 1; i++) {
    //    //双字词分析;
    //    NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
    //    NSDictionary *findLocalWord = [[SMG sharedInstance].store.mkStore getWord:checkWord];
    //    if (findLocalWord) {
    //        [oldArr addObject:findLocalWord];
    //    }else{
    //        NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
    //        if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
    //            [newArr addObject:checkWord];
    //        }
    //    }
    //}
    //2,循环找text中的新词(支持多字词分析)
    NSInteger curIndex = 0;//解析到的下标
    while (curIndex < text.length) {
        NSString *checkStr = [text substringFromIndex:curIndex];//找词字符串
        NSInteger maxWordLength = MIN(10, checkStr.length);     //词最长10个字
        for (NSInteger i = maxWordLength; i > 0; i--) {
            NSString *checkWord = [checkStr substringToIndex:i];
            NSDictionary *findLocalWord = [[SMG sharedInstance].store.mkStore getWord:checkWord];
            if (findLocalWord) {//是旧词
                [oldArr addObject:findLocalWord];
                curIndex += i;
                break;
            }else{//不是旧词
                NSInteger *sumNone = 0;//有0边是词,需要10次;
                NSInteger *sumOne = 0;//有1边是词,需要6次;
                NSInteger *sumTwo = 0;//有2边是词,需要3次;
                NSInteger *sumAll = 0;//全句都是词时,可分析是否为词,是词时直接1次即可;如:小花吃饭了,(小花是局部名词)
                
                NSArray *allMem = [[SMG sharedInstance].store.memStore getMemoryWithWhereDic:nil];
                for (NSDictionary *itemMem in allMem) {
                    NSString *memText = [itemMem objectForKey:@"text"];
                    if ([SMGUtils compareItemA:memText containsItemB:checkWord]) {
                        //1,找词位置
                        NSRange range = [memText rangeOfString:checkWord];
                        //2,左右撞击边缘
                        BOOL hitLeft = (range.location <= 0 || [self checkLeftInsideIsWordWithText:memText index:range.location]);
                        BOOL hitRight = (range.location + range.length >= memText.length || [self checkRightInsideIsWordWithText:memText index:range.location + range.length]);
                        //3,累计词频
                        if (hitLeft && hitRight) sumTwo ++;
                        if (hitLeft || hitRight) sumOne ++;
                        sumNone ++;
                        //4,判断结果
                        if (sumNone >= 10 || sumOne >= 6 || sumTwo >= 3) {
                            [newArr addObject:checkWord];
                            curIndex += i;
                            break;
                        }
                    }
                }
            }
        }
    }
    //3,返回数据
    if (outBlock) {
        outBlock(oldArr,newArr);
    }

}


/**
 *  MARK:--------------------从'记忆'中找到需要'理解'处理的数据--------------------
 *  value:中的元素数据格式:{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}
 */
+(NSMutableArray*) getNeedUnderstandMemoryWithObjId:(NSString*)objId{
    if (STRISOK(objId)) {
        //2,取相关记忆
        NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:@[objId],@"obj", nil];
        NSMutableArray *memArr = [[SMG sharedInstance].store.memStore getMemoryWithWhereDic:where];
        return [self getNeedUnderstandMemoryWithMemArr:memArr];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithDoId:(NSString*)doId{
    if (STRISOK(doId)) {
        //2,取相关记忆
        NSMutableArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWithDoId:doId limit:10];
        return [self getNeedUnderstandMemoryWithMemArr:memArr];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithMemArr:(NSMutableArray*)memArr{
    if (!ARRISOK(memArr)) {
        return nil;
    }
    //1,申请收集数据的数组
    __block NSMutableArray *unknownWordArr = [[NSMutableArray alloc] init];
    NSMutableArray *unknownObjArr = [[NSMutableArray alloc] init];
    NSMutableArray *unknownDoArr = [[NSMutableArray alloc] init];
    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
    //2,收集数据
    for (NSDictionary *memItem in memArr) {
        //memItem结构:{do=[feelDoModel],obj=[10,12],text=@"asdf"}
        //条件1,取未理解元素和;不能>3
        if ([memItem objectForKey:@"obj"]) {
            for (NSString *objId in [memItem objectForKey:@"obj"]) {
                NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:objId,@"objId", nil];
                if(![[SMG sharedInstance].store.mkStore containerWordWithWhere:where]){
                    [unknownObjArr addObject:objId];
                }
            }
        }
        if ([memItem objectForKey:@"do"]) {
            for (NSDictionary *item in [memItem objectForKey:@"do"]) {
                NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"doId"],@"doId", nil];
                if(![[SMG sharedInstance].store.mkStore containerWordWithWhere:where]){
                    [unknownDoArr addObject:[item objectForKey:@"doId"]];
                }
            }
        }
        if (unknownDoArr.count + unknownObjArr.count <= 3) {
            //条件2,不能有未分词的陌生词;
            [UnderstandUtils getWordArrAtText:[memItem objectForKey:@"text"] outBlock:^(NSArray *oldWordArr, NSArray *newWordArr) {
                if (!ARRISOK(newWordArr)) {
                    for (NSDictionary *oldWord in oldWordArr) {
                        if (![oldWord objectForKey:@"objId"] && ![oldWord objectForKey:@"doId"]) {
                            [unknownWordArr addObject:oldWord];
                        }
                    }
                    //条件3,未理解的分词数量差<2;
                    NSInteger diffCount = unknownWordArr.count - unknownDoArr.count - unknownObjArr.count;
                    if (diffCount < 2 && diffCount > -2) {
                        NSDictionary *valueItem = [NSDictionary dictionaryWithObjectsAndKeys:unknownObjArr,@"unknowObjArr",unknownDoArr,@"unknowDoArr",unknownWordArr,@"unknowWordArr",nil];
                        [valueArr addObject:valueItem];
                    }
                }
            }];
        }
    }
    return valueArr;
}


/**
 *  MARK:--------------------private--------------------
 */
//检测Index左侧是否为词
+(BOOL) checkLeftInsideIsWordWithText:(NSString*)text index:(NSInteger)index{
    text = STRTOOK(text);
    //1,左侧没字了,不是词 | index越界了,不是词
    if (index <= 0 || index > text.length) {
        return false;
    }
    //2,检查最长7个字范围是不是词
    NSInteger maxLength = MIN(index, 7);
    for (NSInteger i = 1; i <= maxLength; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(index - i, i)];
        if ([[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            return true;
        }
    }
    return false;
}

//检测Index右侧是否为词
+(BOOL) checkRightInsideIsWordWithText:(NSString*)text index:(NSInteger)index{
    text = STRTOOK(text);
    //1,左侧没字了,不是词 | index越界了,不是词
    if (index >= text.length || index < 0) {
        return false;
    }
    //2,检查最长7个字范围是不是词
    NSInteger maxLength = MIN(text.length - index, 7);
    for (NSInteger i = 1; i <= maxLength; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(index, i)];
        if ([[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            return true;
        }
    }
    return false;
}

@end
