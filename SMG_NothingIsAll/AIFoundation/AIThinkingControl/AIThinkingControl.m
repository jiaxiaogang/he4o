//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "AIMindValue.h"
#import "AIStringAlgsModel.h"
#import "AIInputMindValueAlgsModel.h"
#import "AIActionControl.h"
#import "AINode.h"
#import "AIModel.h"
#import "NSObject+Extension.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *cacheShort;//存AIModel(从Algs传入,待Thinking取用分析)(容量8);
@property (strong,nonatomic) NSMutableArray *cacheLong;//存AINode(相当于Net的缓存区)(容量10000);

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
    self.cacheShort = [[NSMutableArray alloc] init];
    self.cacheLong = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) activityByShallow:(id)data{
    //1. update Caches;
    [self addObjectToCaches:data];
    
    //2. check data hav mv;
    if ([self objectHavMV:data]) { //hav mv
        [self activityByDeep:nil mvData:data];
        return;
    }
    
    //3. if not find mv from caches,then try find actionControl;(充mv)
    [[AIActionControl shareInstance] searchModel_Induction:data block:^(AINode *result) {
        id mvResult = [self objectForNetModelConvertToMV:result];
        if (mvResult) {
            [self activityByDeep:result mvData:mvResult];
        }
    }];
}


/**
 *  MARK:--------------------思维发现imv,制定cmv,分析实现cmv;--------------------
 *  参考:n9p20
 */
-(void) activityByDeep:(AINode*)netModel mvData:(AIInputMindValueAlgsModel*)mvData{
    //1. check mvData;
    if (mvData == nil) {
        return;
    }
    
    //2. updateModel
    [[AIActionControl shareInstance] insertModel:mvData];//xxx作inputModel到aiModel的转换...
    NSDictionary *dic = [NSObject getObjectData:mvData];
    NSLog(@"");
    
    
    
    
    //3. find cmvLogic;
    [[AIActionControl shareInstance] searchModel_Logic:mvData block:^(AINode *result) {
        if (result) {
            
        }else{
            
        }
    }];
    
    //4. 关联分析caches和netModel等当前数据;
    
}


-(void) activityByNone:(id)data{
    NSLog(@"创建后台任务");
}

//MARK:===============================================================
//MARK:                     < caches >
//MARK:===============================================================
-(void) addObjectToCaches:(id)data{
    if (data) {
        [self.cacheShort addObject:data];
    }
    if (self.cacheShort.count > 8) {
        [self.cacheShort removeObjectAtIndex:0];
    }
}

//found mv;
-(BOOL) objectHavMV:(id)data{
    return data && (ISOK(data, AIInputMindValueAlgsModel.class));//||MindValue.class
}

-(id) objectForNetModelConvertToMV:(AINode*)model{
    if (model) {
        return model;
    }
    return nil;
}

@end


//1. 抽象"饥饿感神经"与电量变化的连接常识;(类比操作)
//NSArray *LawArr = [SMGUtils lightArea_AILineTypeIsLawWithLightModels:models];


//2. 与当前curTask对比,是否解决,是否继续,是否...
//BOOL win = true;


//3. ThinkDemand的解;
//1,依赖于经验等数据;
//2,依赖与常识的简单解决方案;(类比)
//3,复杂的问题分析(多事务,加缓存,加分析)


//4. 老旧思维解决问题方式
//A. 搜索强化经验(经验表)
    //1),参照解决方式,
    //2),类比其常识,
    //3),制定新的解决方式,
    //4),并分析其可行性, & 修正
    //5),预测其结果;(经验中上次的步骤对比)
    //6),执行输出;
//B. 搜索未强化经历(意识流)
    //1),参照记忆,
    //2),尝试执行输出;
    //3),反馈(观察整个执行过程)
    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
    //5),转移到经验表;
//C. 无
    //1),取原始情绪表达方式(哭,笑)(是急哭的吗?)
    //3),记忆(观察整个执行过程)


//5. 忙碌状态;
//-(BOOL) isBusy{return false;}

//6. 单次为比的结果;
//@property (assign, nonatomic) ComparisonType comparisonType;    //比较结果(toFeelId/fromFeelId)
