//
//  AIThinkingRule.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingRule.h"
#import "AINet.h"

@interface AIThinkingRule()

@end

@implementation AIThinkingRule

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) activityByShallow:(id)data{
    if (ISOK(data, NSString.class)) {
        [theNet commitString:data];//潜思维,识别;
    }
}
-(void) activityByDeep:(id)data{
    
}
-(void) activityByNone:(id)data{
    NSLog(@"创建后台任务");
}

@end
