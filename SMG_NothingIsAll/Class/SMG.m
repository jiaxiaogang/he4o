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
#import "ThinkHeader.h"
#import "InputHeader.h"
#import "FeelHeader.h"
#import "OutputHeader.h"
#import "MindHeader.h"


@interface SMG ()<FeelDelegate,MindControlDelegate,ThinkControlDelegate>

@end

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
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.store      = [[Store alloc] init];
    self.mindControl= [[MindControl alloc] init];
    self.thinkControl = [[ThinkControl alloc] init];
    self.feel       = [[Feel alloc] init];
    self.output     = [[Output alloc] init];
}

-(void) initRun{
    self.feel.delegate = self;
    self.mindControl.delegate = self;
    self.thinkControl.delegate = self;
}

/**
 *  MARK:--------------------FeelDelegate--------------------
 */
-(void)feel_CommitToThink:(id)feelData{
    NSLog(@"Feel_提交到SMG");
}

/**
 *  MARK:--------------------MindControlDelegate--------------------
 */
-(void) mindControl_AddDemand:(id)demand withType:(MindType)type{
    NSLog(@"Mind需求_提交到SMG");
    [self.thinkControl commitDemand:demand withType:type];
}

/**
 *  MARK:--------------------ThinkControlDelegate--------------------
 */
-(void)thinkControl_GetMoodValue:(AIPointer *)pointer{
    NSLog(@"Think问Mind是否喜欢某物_提交到SMG");
}

@end
