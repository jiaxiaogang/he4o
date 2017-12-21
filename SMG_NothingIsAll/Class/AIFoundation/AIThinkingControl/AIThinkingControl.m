//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "AIHungerLevelChangedModel.h"
#import "AIHungerStateChangedModel.h"
#import "AIInputMindValue.h"

@interface AIThinkingControl()

@end

@implementation AIThinkingControl

static AIThinkingControl *_instance;
+(AIThinkingControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIThinkingControl alloc] init];
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
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) activityByShallow:(id)data{
    if (ISOK(data, NSString.class)) {
        [theNet commitString:data];//潜思维,识别;
    }else if(ISOK(data, AIHungerLevelChangedModel.class)){
        //1. data的信息总会经过神经元生成为神经网络;只是无关联会很快GC掉;
        [theNet commitModel:data];
        //2. mindValue提纯后,用于构建神经网络关联;
        //3. mindVaue能否被存储?(应该会存储自我的mindValue快乐状态,mindValue具有影响构建和可数据表示二象性,mindValue原本不是一条数据,但因被自我状态感知了,才变成数据)
    }else if(ISOK(data, AIHungerStateChangedModel.class)){
        [theNet commitModel:data];
    }else if(ISOK(data, AIInputMindValue.class)){
        NSLog(@"_________shadowForIMV");
        //思维对imv发生时,前后4个左右的思维缓存区作分析与关联操作;
    }
}
-(void) activityByDeep:(id)data{
    
}
-(void) activityByNone:(id)data{
    NSLog(@"创建后台任务");
}

@end
