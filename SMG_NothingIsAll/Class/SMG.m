//
//  SMG.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMG.h"
#import "SMGHeader.h"
#import "TextHeader.h"
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
    self.text = [[Text alloc] init];
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
        complete([self.text outputTextWithRequestText:text withStoreModel:mem]);
}

-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType {
    //1,找到上关记忆;
    //2,有则根据mind值update记忆;
    //3,无则根据回复I can't undestand;
}





@end
