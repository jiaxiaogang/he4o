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
#import "ThinkHeader.h"

@interface Understand ()

@property (strong,nonatomic) NSMutableDictionary *mDic; //数据;

@end

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

/**
 *  MARK:--------------------min想--------------------
 *  冥想是逻辑整理的关键;(人工智能在闲暇时间,冥想;可以整理逻辑,甚至假设逻辑,然后在现实中验证假设)
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
    [TextStore addWordWithTextArr:newWords];
    //3,存Logic
    //...
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end



