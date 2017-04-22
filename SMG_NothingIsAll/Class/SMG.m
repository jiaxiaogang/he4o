//
//  SMG.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMG.h"
#import "SMGHeader.h"
#import "GC.h"
#import "StoreHeader.h"
#import "UnderstandHeader.h"
#import "InputHeader.h"
#import "FeelHeader.h"

@implementation SMG

static SMG *_instance;
+(SMG*) sharedInstance{
    if (_instance == nil) {
        _instance = [[SMG alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.store = [[Store alloc] init];
    self.gc = [[GC alloc] init];
    self.mind = [[Mind alloc] init];
    self.understand = [[Understand alloc] init];
    self.feel = [[Feel alloc] init];
}

/**
 *  MARK:--------------------method--------------------
 */

//MARK:--------------------QA--------------------
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete{
    text = STRTOOK(text);
    //1,心情不好时,不回答,(需要安慰加心情值再聊)
    if (self.mind.sadHappyValue < -5) {
        if (complete)
            complete(@"🔥");
        return;
    }
    
    //2,搜记忆;
    NSDictionary *mem = [self.store searchMemStoreWithLanguageText:text];
    
    //3,Language系统输出回复;
    if (complete)
        complete([self outputTextWithRequestText:text withStoreModel:mem]);
}

-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType {
    //1,找到上关记忆;
    //2,有则根据mind值update记忆;
    //3,无则根据回复I can't undestand;
}



/**
 *  MARK:--------------------语言输出能力--------------------
 *
 *  1,不理解的不回答;
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
    if (self.mind.sadHappyValue < 0) {
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




@end
