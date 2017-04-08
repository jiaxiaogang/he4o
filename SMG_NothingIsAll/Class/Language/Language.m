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

@implementation Language


/**
 *  MARK:--------------------语言输出能力--------------------
 */
-(NSString*) outputTextWithRequestText:(NSString*)requestText withStoreModel:(LanguageStoreModel*)storeModel{
    
    //1,有记忆根据mind值排序回复;(找到习惯系统中的最佳回答)
    if (storeModel && storeModel.logArr && storeModel.logArr.count) {
        NSArray *sortArr = [storeModel.logArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return ((LanguageStoreLogModel*)obj1).powerValue < ((LanguageStoreLogModel*)obj2).powerValue;
        }];
        LanguageStoreLogModel *logModel = sortArr[0];
        if (logModel.powerValue > 0 ) {
            return logModel.text;
        }
    }
    //2,无记忆则根据Language系统输出回复;
    if (complete)
        complete([self.language outputTextWithRequestText:text withStoreModel:model]);
    
    
    
    
    //1,模糊搜索记忆
    NSArray *arr = [[SMG sharedInstance].store searchMemStoreContainerText:STRTOOK(requestText)];
    //2,有时,找匹配项
    if (arr) {
        for (LanguageStoreModel *storeModel in arr) {
            if(storeModel.logArr){
                for (LanguageStoreLogModel *logModel in storeModel.logArr) {
                    if (logModel.powerValue > 2) {
                        return logModel.text;
                    }
                }
            }
        }
    }
    //3,无时,判断交流欲望(心情不好时,不回答)
    if ([SMG sharedInstance].mind.sadHappyValue < 0) {
        return @"(▭-▭)✧";//淡定;
    }
    //4,开心时,随机返回点东西;
    withStoreModel
    //5,不开心时,可以不理对方;
    return nil;
}


/**
 *  MARK:--------------------用于分析语言输入,并且找出规律词和图谱词并返回--------------------
 *
 */
-(NSArray*) inputTextWithRequestText:(NSString*)requestText{
    return nil;
}



@end
