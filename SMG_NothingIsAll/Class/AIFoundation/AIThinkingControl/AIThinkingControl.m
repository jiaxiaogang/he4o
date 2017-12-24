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
#import "AIMindValue.h"
#import "AIStringAlgsModel.h"
#import "AIInputMindValueAlgsModel.h"
#import "AIActionControl.h"
#import "AINetModel.h"
#import "AIModel.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *caches;

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
    self.caches = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) activityByShallow:(id)data{
    if (ISOK(data, AIStringAlgsModel.class)) {
        NSLog(@"_________shadowForNoMV");//无mv
        
        
        //1. 尝试从caches取mv邻居;
        for (id cache in self.caches) {
            if ([self objectHavMV:cache]) {
                //发现最近有mv;
                //1. 制定cmv目标;
                //2. 查找其cmv经验;
                [[AIActionControl shareInstance] searchModel:cache type:MultiNetType_Experience block:^(AINetModel *result) {
                    
                }];
            }
        }
        
        //2. 潜思维,识别;
        [self addObjectToCaches:data];
        
        //3. 到Net检索相关;
        [[AIActionControl shareInstance] searchModel:data type:MultiNetType_String block:^(AINetModel *result) {
            if (result) {
                [self actionControlBlockWithResult:result];
            }else{
                [[AIActionControl shareInstance] insertModel:data];
            }
        }];
        
        //4. 从数据中发现cmv目标;并且从经验中寻找cmv的实现方式;形成思维的整个过程;(参考n9p20)
    }else if(ISOK(data, AIInputMindValueAlgsModel.class)) {
        NSLog(@"_________shadowForIMV");//有mv...
        //1. 思维对imv发生时,前后4个左右的思维缓存区作分析与关联操作;
        [self addObjectToCaches:data];
        
        //2. 与caches作关联分析;
        
    }else if(ISOK(data, AIHungerLevelChangedModel.class)) {
        //1. data的信息总会经过神经元生成为神经网络;只是无关联会很快GC掉;
        [theNet insertModel:data];
        //2. mindValue提纯后,用于构建神经网络关联;
        //3. mindVaue能否被存储?(应该会存储自我的mindValue快乐状态,mindValue具有影响构建和可数据表示二象性,mindValue原本不是一条数据,但因被自我状态感知了,才变成数据)
    }else if(ISOK(data, AIHungerStateChangedModel.class)){
        [theNet insertModel:data];
    }
}
-(void) activityByDeep:(id)data{
    
}
-(void) activityByNone:(id)data{
    NSLog(@"创建后台任务");
}

//MARK:===============================================================
//MARK:                     < caches >
//MARK:===============================================================
-(void) addObjectToCaches:(id)data{
    if (data) {
        [self.caches addObject:data];
    }
    if (self.caches.count > 4) {
        [self.caches removeObjectAtIndex:0];
    }
}

-(BOOL) objectHavMV:(id)data{
    return data && (ISOK(data, AIInputMindValueAlgsModel.class));//||MindValue.class
}

//MARK:===============================================================
//MARK:                     < actionControl >
//MARK:===============================================================
-(void) actionControlBlockWithResult:(AINetModel*)result {
    NSLog(@"___NETResult");
}

@end
