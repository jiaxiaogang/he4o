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



/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
-(NSArray*) analyzeText:(NSString*)text{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    NSArray *memArr = [[SMG sharedInstance] getStore_MemStore_MemArr];//习惯池
    //2,循环找text中的词
    for (int i = 0; i < text.length; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        if ([[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            [mArr addObject:checkWord];
        }else{
            for (StoreModel_Text *model in memArr) {
                
            }
        }
    }
    
    
    return nil;
}


@end
