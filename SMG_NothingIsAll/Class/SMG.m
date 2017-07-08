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

@interface SMG ()<FeelDelegate,MindControlDelegate,ThinkControlDelegate,InputDelegate>

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
    self.input = [[Input alloc] init];
}

-(void) initRun{
    self.feel.delegate = self;
    self.mindControl.delegate = self;
    self.thinkControl.delegate = self;
    self.input.delegate = self;
}

/**
 *  MARK:--------------------InputDelegate--------------------
 */
-(void)input_CommitToThink:(NSString *)text{
    NSLog(@"Input->Think (CONTENT:(%@)",text);
    [self.thinkControl commitUnderstandByShallow:text];//从input常规输入的浅度理解即可;
}

/**
 *  MARK:--------------------FeelDelegate--------------------
 */
-(void)feel_CommitToThink:(id)feelData{
    
}

/**
 *  MARK:--------------------MindControlDelegate--------------------
 */
-(void) mindControl_CommitDecisionByDemand:(id)demand withType:(MindType)type{
    [self.thinkControl commitDemand:demand withType:type];
}

/**
 *  MARK:--------------------ThinkControlDelegate--------------------
 */
-(id)thinkControl_GetMindValue:(AIPointer *)pointer{
    NSLog(@"Think问Mind是否喜欢某物_提交到SMG");
    return [self.mindControl getMindValue:pointer];
}

-(NSString*) thinkControl_TurnDownDemand:(id)demand type:(MindType)type{
    return [self.mindControl turnDownDemand:demand type:type];
}


@end
