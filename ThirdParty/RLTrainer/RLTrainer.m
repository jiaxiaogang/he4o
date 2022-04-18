//
//  RLTrainer.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RLTrainer.h"
#import "RTModel.h"
#import "RLTPanel.h"

@interface RLTrainer () <RTModelDelegate,RLTPanelDelegate>

@property (strong, nonatomic) RTModel *model;
@property (strong, nonatomic) RLTPanel *panel;

@end

@implementation RLTrainer

static RLTrainer *_instance;
+(RLTrainer*) sharedInstance{
    if (_instance == nil) {
        _instance = [[RLTrainer alloc] init];
    }
    return _instance;
}

-(id) init {
    self = [super init];
    if(self != nil){
        [self initData];
    }
    return self;
}

-(void) initData{
    self.model = [[RTModel alloc] init];
    self.model.delegate = self;
    self.panel = [[RLTPanel alloc] init];
    self.panel.delegate = self;
    [theApp.window addSubview:self.panel];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector{
    [self.model regist:name target:target selector:selector];
}
-(void) queue1:(NSString*)name{
    [self.model queue:@[name] count:1];
}
-(void) queue1:(NSString*)name count:(NSInteger)count{
    [self.model queue:@[name] count:count];
}
-(void) queueN:(NSArray*)names count:(NSInteger)count{
    [self.model queue:names count:count];
}

//MARK:===============================================================
//MARK:                     < RTModelDelegate >
//MARK:===============================================================
-(BOOL)RTModel_Playing{
    return self.panel.playing;
}

//MARK:===============================================================
//MARK:                     < RLTPanelDelegate >
//MARK:===============================================================
-(void)RLTPanel_Stop{
    
}

@end
