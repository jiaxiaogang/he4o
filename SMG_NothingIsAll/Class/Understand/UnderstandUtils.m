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
    text = STRTOOK(text);
    NSMutableArray *oldArr = [[NSMutableArray alloc] init];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    //2,循环找text中的新词
    for (int i = 0; i < text.length - 1; i++) {
        //双字词分析;
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        NSDictionary *findLocalWord = [[SMG sharedInstance].store.mkStore containerWord:checkWord];
        if (findLocalWord) {
            [oldArr addObject:findLocalWord];
        }else{
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [newArr addObject:checkWord];
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
        return [self getNeedUnderstandMemoryWithWhereDic:[NSDictionary dictionaryWithObjectsAndKeys:objId,@"obj", nil]];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithDoId:(NSString*)doId{
    if (STRISOK(doId)) {
        return [self getNeedUnderstandMemoryWithWhereDic:[NSDictionary dictionaryWithObjectsAndKeys:doId,@"do", nil]];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithWhereDic:(NSDictionary*)whereDic{
    //1,申请收集数据的数组
    __block NSMutableArray *unknownWordArr = [[NSMutableArray alloc] init];
    NSMutableArray *unknownObjArr = [[NSMutableArray alloc] init];
    NSMutableArray *unknownDoArr = [[NSMutableArray alloc] init];
    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
    //2,取相关记忆
    NSMutableArray *memArr = [[SMG sharedInstance].store.memStore getMemoryWithWhereDic:whereDic];
    if (memArr) {
        for (NSDictionary *memItem in memArr) {
            //条件1,取未理解元素和;不能>3
            if ([memItem objectForKey:@"obj"]) {
                for (NSDictionary *item in [memItem objectForKey:@"obj"]) {
                    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"itemId"],@"objId", nil];
                    if(![[SMG sharedInstance].store.mkStore containerWordWithWhere:where]){
                        [unknownObjArr addObject:[item objectForKey:@"itemId"]];
                    }
                }
            }
            if ([memItem objectForKey:@"do"]) {
                for (NSDictionary *item in [memItem objectForKey:@"do"]) {
                    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"itemId"],@"doId", nil];
                    if(![[SMG sharedInstance].store.mkStore containerWordWithWhere:where]){
                        [unknownDoArr addObject:[item objectForKey:@"itemId"]];
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
    }
    return valueArr;
}

@end
