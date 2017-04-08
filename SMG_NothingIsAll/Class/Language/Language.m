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
-(NSString*) outputTextWithRequestText:(NSString*)requestText{
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
