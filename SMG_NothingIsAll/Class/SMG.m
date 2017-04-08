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

/**
 *  MARK:--------------------问话--------------------
 */
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete{
    text = STRTOOK(text);
    //1,搜记忆;
    LanguageStoreModel *model = [self.store searchMemStoreWithLanguageText:text];
    if (model) {
        model.
    }
    //2,有则根据mind值回复;
    //3,无则根据mind值回复;
}

-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType {
    //1,找到上关记忆;
    //2,有则根据mind值update记忆;
    //3,无则根据回复I can't undestand;
}

@end
