//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AIShortMemory.h"
#import "DemandManager.h"
#import "AIThinkIn.h"
#import "AIThinkOut.h"
#import "OutputModel.h"
#import "AINet.h"
#import "AINetUtils.h"
#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "AIAlgNode.h"
#import "AINetIndex.h"



//TODOTOMORROW:
//a. actionScheme T
//b. mvScheme T
//c. foScheme T
//d. algScheme.TOAlgScheme T
//UseMemNet To TC





/**
 *  MARK:--------------------思维控制器--------------------
 *
 *  >> ThinkIn & ThinkOut
 *
 *  >> assExp
 *  1. 在联想中,遇到的数据,都存到thinkFeedCache;
 *  2. 在联想中,遇到的mv,都叠加到当前demand下;
 *
 */
@interface AIThinkingControl() <AIThinkInDelegate,AIThinkOutDelegate>

@property (strong,nonatomic) AIShortMemory *shortMemory;
@property (strong,nonatomic) NSMutableArray *thinkFeedCache;    //短时记忆_思维流(包括shortCache和cmvCache,10分钟内都会存在此处(人类可能一天或几小时))
@property (strong, nonatomic) DemandManager *demandManager;   //输出循环所用到的数据管理器;
@property (assign, nonatomic) NSInteger energy;                 //当前能量值;(mv输入时激活,思维的循环中消耗)

@property (strong, nonatomic) AIThinkIn *thinkIn;
@property (strong, nonatomic) AIThinkOut *thinkOut;

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
    }
    return self;
}

-(void) initData{
    self.shortMemory = [[AIShortMemory alloc] init];
    self.thinkFeedCache = [[NSMutableArray alloc] init];
    self.demandManager = [[DemandManager alloc] init];
    self.thinkIn = [[AIThinkIn alloc] init];
    self.thinkIn.delegate = self;
    self.thinkOut = [[AIThinkOut alloc] init];
    self.thinkOut.delegate = self;
}


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    [self.thinkIn dataIn:algsModel];
}

-(void) commitInputWithModels:(NSArray*)models{
    [self.thinkIn dataInWithModels:models];
}

-(void) commitOutputLog:(NSArray*)outputModels{
    //1. 数据
    NSMutableArray *value_ps = [[NSMutableArray alloc] init];
    for (OutputModel *model in ARRTOOK(outputModels)) {
        //2. 装箱
        AIKVPointer *output_p = [theNet getOutputIndex:model.rds outputObj:model.data];
        if (output_p) {
            [value_ps addObject:output_p];
        }
        
        //4. 记录可输出canout (当前善未形成node,所以无法建议索引;(检查一下,当outLog形成node后,索引的建立))
        [AINetUtils setCanOutput:model.rds];
    }
    
    //5. 祖母
    AIAlgNode *algNode = [theNet createAlgNode:value_ps isOut:true isMem:false];
    
    //6. 加瞬时记忆
    [self.shortMemory addToShortCache_Ps:@[algNode.pointer]];
}


//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------更新energy--------------------
 */
-(void) updateEnergy:(NSInteger)delta{
    self.energy = [ThinkingUtils updateEnergy:self.energy delta:delta];
}


/**
 *  MARK:--------------------AIThinkInDelegate--------------------
 */
-(void)aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps{
    [self.shortMemory addToShortCache_Ps:algNode_ps];
}

-(AIFrontOrderNode*)aiThinkIn_CreateCMVModel:(NSArray *)algsArr{
    AIFrontOrderNode *foNode = [[AINet sharedInstance] createCMV:algsArr order:self.shortMemory.shortCache];
    [self.shortMemory clear];
    return foNode;
}

-(void) aiThinkIn_CommitMvNode:(AICMVNodeBase*)cmvNode{
    //1. 数据检查
    if (!ISOK(cmvNode, AICMVNodeBase.class)) {
        return;
    }
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) {
        return;
    }
    
    //2. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    [self updateEnergy:((urgentTo + 9)/10)];
    [self.demandManager updateCMVCache:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    [self.thinkOut dataOut];
}

-(void) aiThinkIn_UpdateEnergy:(NSInteger)delta{
    [self updateEnergy:delta];
}

-(BOOL) aiThinkIn_EnergyValid{
    return self.energy > 0;
}


/**
 *  MARK:--------------------AIThinkOutDelegate--------------------
 */
-(DemandModel*) aiThinkOut_GetCurrentDemand{
    return [self.demandManager getCurrentDemand];
}

-(BOOL) aiThinkOut_EnergyValid{
    return self.energy > 0;
}

-(void) aiThinkOut_UpdateEnergy:(NSInteger)delta{
    [self updateEnergy:delta];
}

@end
