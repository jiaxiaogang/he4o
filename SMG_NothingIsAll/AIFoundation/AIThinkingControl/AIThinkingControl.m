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
#import "AIThinkOutPercept.h"
#import "AIThinkOutReason.h"
#import "OutputModel.h"
#import "AINet.h"
#import "AINetUtils.h"
#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "AIAlgNode.h"
#import "AINetIndex.h"
#import "NSObject+Extension.h"
#import "AIShortMatchModel.h"
#import "TOFoModel.h"

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
@interface AIThinkingControl() <AIThinkInDelegate,AIThinkOutPerceptDelegate,AIThinkOutReasonDelegate>

@property (strong,nonatomic) AIShortMemory *shortMemory;    //瞬时记忆
@property (strong, nonatomic) DemandManager *demandManager; //输出循环所用到的数据管理器;

/**
 *  MARK:--------------------当前能量值--------------------
 *  1. 激活: mv输入时激活;
 *  2. 消耗: 思维的循环中消耗;
 *      1. 构建"概念节点"消耗0.1;
 *      2. 构建"时序节点"消耗1;
 *
 *  3. 范围: 0-20;
 */
@property (assign, nonatomic) CGFloat energy;

@property (strong, nonatomic) AIThinkIn *thinkIn;
@property (strong, nonatomic) AIThinkOutPercept *tOP;       //感性决策
@property (strong, nonatomic) AIThinkOutReason *tOR;        //理性决策

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
    self.demandManager = [[DemandManager alloc] init];
    self.thinkIn = [[AIThinkIn alloc] init];
    self.thinkIn.delegate = self;
    self.tOP = [[AIThinkOutPercept alloc] init];
    self.tOP.delegate = self;
    self.tOR = [[AIThinkOutReason alloc] init];
    self.tOR.delegate = self;
}


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    NSDictionary *modelDic = [NSObject getDic:algsModel containParent:true];
    NSString *algsType = NSStringFromClass(algsModel.class);
    [self.thinkIn dataIn:modelDic algsType:algsType];
}

-(void) commitInputWithModels:(NSArray*)dics algsType:(NSString*)algsType{
    [self.thinkIn dataInWithModels:dics algsType:algsType];
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
    
    //5. 概念
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
-(void) updateEnergy:(CGFloat)delta{
    self.energy = [ThinkingUtils updateEnergy:self.energy delta:delta];
    NSLog(@"inner > delta:%f = energy:%f",delta,self.energy);
}


/**
 *  MARK:--------------------AIThinkInDelegate--------------------
 */
-(void)aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps{
    [self.shortMemory addToShortCache_Ps:algNode_ps];
}

-(NSArray*) aiThinkIn_GetShortMemory{
    return self.shortMemory.shortCache;
}

-(AIFrontOrderNode*)aiThinkIn_CreateCMVModel:(NSArray *)algsArr{
    AIFrontOrderNode *foNode = [[AINet sharedInstance] createCMV:algsArr order:self.shortMemory.shortCache];
    [self.shortMemory clear];
    return foNode;
}

-(void) aiThinkIn_CommitPercept:(AICMVNodeBase*)cmvNode{
    //1. 数据检查
    if (!ISOK(cmvNode, AICMVNodeBase.class)) {
        return;
    }
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) {
        return;
    }
    
    //2. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [self updateEnergy:urgentTo];//190730前:((urgentTo + 9)/10) 190730:urgentTo
    [self.demandManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta order:urgentTo];
    [self.tOP dataOut];
}

-(void) aiThinkIn_Commit2TC:(AIShortMatchModel*)shortMatchModel {
    //1. 把mv加入到demandManager;
    NSInteger urgentTo = 0;
    if (shortMatchModel && shortMatchModel.matchFo) {
        //1> 判断matchingFo.mv有值才加入demandManager,同台竞争,执行顺应mv;
        AICMVNodeBase *mvNode = [SMGUtils searchNode:shortMatchModel.matchFo.cmvNode_p];
        if (mvNode) {
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            if (delta != 0) {
                NSString *algsType = mvNode.urgentTo_p.algsType;
                
                //2> 判断matchValue的匹配度,对mv的迫切度产生"正相关"影响;
                urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
                urgentTo = (int)(urgentTo * shortMatchModel.matchFoValue);
                
                //3> 将mv加入demandCache
                [self.demandManager updateCMVCache_RMV:algsType urgentTo:urgentTo delta:delta order:urgentTo];
                
                //4> RMV无需求时;
                BOOL havDemand = [ThinkingUtils getDemand:algsType delta:delta complete:nil];
                if (!havDemand) {
                    NSLog(@"当前,预测mv未形成需求;");
                }
            }
        }
    }
    
    //2. 加上活跃度
    [self updateEnergy:urgentTo];
    
    //3. 将shortMatch提交给TOR;
    [self.tOR commitFromTIR:shortMatchModel];
    
    //4. 激活dataOut
    [self.tOP dataOut];
}

-(void) aiThinkIn_UpdateEnergy:(CGFloat)delta{
    [self updateEnergy:delta];
}

-(BOOL) aiThinkIn_EnergyValid{
    return self.energy > 0;
}


/**
 *  MARK:--------------------AIThinkOutPerceptDelegate--------------------
 */
-(DemandModel*) aiThinkOutPercept_GetCurrentDemand{
    return [self.demandManager getCurrentDemand];
}

-(BOOL) aiThinkOutPercept_EnergyValid{
    return self.energy > 0;
}

-(void) aiThinkOutPercept_UpdateEnergy:(CGFloat)delta{
    [self updateEnergy:delta];
}

-(void) aiThinkOutPercept_Commit2TOR:(TOFoModel*)foModel{
    [self.tOR commitFromTOP_Convert2Actions:foModel];
}

-(void) aiThinkOutPercept_MVSchemeFailure{
    [self.tOR commitFromTOP_ReflexOut];
}

/**
 *  MARK:--------------------AIThinkOutReasonDelegate--------------------
 */
-(void) aiThinkOutReason_UpdateEnergy:(CGFloat)delta{
    [self updateEnergy:delta];
}
-(BOOL) aiThinkOutReason_EnergyValid {
    return self.energy > 0;
}
-(AIShortMatchModel*) aiTOR_LSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps{
    return [self.thinkIn dataInFromTORLSPRethink:rtAlg rtFoContent_ps:rtFoContent_ps];
}

@end
