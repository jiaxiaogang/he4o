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
#import "LanguageHeader.h"

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


-(void) commitFeelModel:(FeelModel*)model{
    
}



//MARK:--------------------开始思考人生--------------------
-(void) startUnderstand{
    //1,分词:最近三条记忆;
    for (int i = 0 ; i < 3; i++) {
        NSArray *memArr = [[SMG sharedInstance] getStore_MemStore_MemArr];
        StoreModel_Text *model = memArr[memArr.count - i - 1];
        [self analyzeText:model.text];
    }
    //2,行为<-->文字
    
    //3,联想
}

/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
//MARK:----------分析分词----------
-(NSArray*) analyzeText:(NSString*)text{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    //2,循环找text中的词
    for (int i = 0; i < text.length; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        if ([[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            [mArr addObject:checkWord]; //本来就有的词;
        }else{
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerWord:checkWord];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [[SMG sharedInstance].store.mkStore addWord:checkWord];
                [mArr addObject:checkWord];
            }
        }
    }
    return mArr;
}


-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end
