//
//  Understand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "FeelHeader.h"
#import "UnderstandHeader.h"

@implementation Understand


-(id) init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) initData{
    self.timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(startUnderstand) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}


/**
 *  MARK:--------------------private--------------------
 */

//MARK:----------找到新的单字分词----------
-(void) getSingleWordArrAtText:(NSString*)text outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr))outBlock{
    //有三次被孤立时,采用;
}


//MARK:----------找到新的逻辑----------
-(NSArray*) getNewLogicArrAtText:(NSString*)text{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    //2,循环找text中的新词
    for (int i = 0; i < text.length - 1; i++) {
        //双字词分析;
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        if (![[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [mArr addObject:checkWord];
            }
        }
    }
    return mArr;
}

/**
 *  MARK:--------------------min想--------------------
 */
-(void) startUnderstand{
    //1,分词:最近三条记忆;(这里以后改成,随机想一条逻辑线,即整理Mk又整理Logic)
    NSArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWhereDic:nil limit:3];
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < memArr.count; i++) {
        NSDictionary *mem = memArr[memArr.count - i - 1];
        [UnderstandUtils getWordArrAtText:[mem objectForKey:@"text"] forceWordArr:nil outBlock:^(NSArray *oldWordArr, NSArray *newWordArr,NSInteger unknownCount) {
            [newWords addObjectsFromArray:newWordArr];
        }];
    }
    //2,存MK
    [[SMG sharedInstance].store.mkStore addWordArr:newWords];
    //3,存Logic
    //...
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end



