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



@end
