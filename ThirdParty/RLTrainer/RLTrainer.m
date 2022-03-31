//
//  RLTrainer.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RLTrainer.h"
#import "RTModel.h"

@interface RLTrainer ()

@property (strong, nonatomic) RTModel *model;

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
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector{
    [self.model regist:name target:target selector:selector];
}
-(void) queue:(NSString*)name{
    [self.model queue:name count:1];
}
-(void) queue:(NSString*)name count:(NSInteger)count{
    [self.model queue:name count:count];
}

@end
