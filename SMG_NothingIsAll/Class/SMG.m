//
//  SMG.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMG.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "UnderstandHeader.h"
#import "InputHeader.h"
#import "FeelHeader.h"
#import "OutputHeader.h"
#import "MindHeader.h"

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
    self.store      = [[Store alloc] init];
    self.mindControl= [[MindControl alloc] init];
    self.understand = [[Understand alloc] init];
    self.feel       = [[Feel alloc] init];
    self.output     = [[Output alloc] init];
}


@end
