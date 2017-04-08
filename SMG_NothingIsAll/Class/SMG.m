//
//  SMG.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMG.h"
#import "SMGHeader.h"
#import "LanguageHeader.h"
#import "GC.h"
#import "Store.h"

@implementation SMG

static SMG *_instance;
+(id) sharedInstance{
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
    self.language = [[Language alloc] init];
    self.mind = [[Mind alloc] init];
}

/**
 *  MARK:--------------------问话--------------------
 */
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete{
    text = STRTOOK(text);
    //1,心情不好时,不回答,(需要安慰加心情值再聊)
    if (self.mind.sadHappyValue < -5) {
        if (complete)
            complete(@"🔥");
        return;
    }
    
    //2,搜记忆;
    LanguageStoreModel *model = [self.store searchMemStoreWithLanguageText:text];
    
    //3,有则根据mind值排序回复;(找到习惯系统中的最佳回答)
    if (model && model.logArr && model.logArr.count) {
        NSArray *sortArr = [model.logArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return ((LanguageStoreLogModel*)obj1).powerValue < ((LanguageStoreLogModel*)obj2).powerValue;
        }];
        LanguageStoreLogModel *logModel = sortArr[0];
        if (logModel.powerValue > 0 && complete) {
            complete(logModel.text);
            return;
        }
    }
    //4,无则根据Language系统输出回复;
    if (complete)
        complete([self.language outputTextWithRequestText:text]);
}

-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType {
    //1,找到上关记忆;
    //2,有则根据mind值update记忆;
    //3,无则根据回复I can't undestand;
}

@end
