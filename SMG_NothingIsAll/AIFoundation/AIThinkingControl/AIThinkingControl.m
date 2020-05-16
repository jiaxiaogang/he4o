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
#import "ShortMatchManager.h"
#import "TOFoModel.h"
#import "AIFrontOrderNode.h"

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
@property (strong, nonatomic) DemandManager *demandManager;         //OUT短时记忆 (输出数据管理器);
@property (strong, nonatomic) ShortMatchManager *shortMatchManager; //IN短时记忆 (输入数据管理器);

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
    self.shortMatchManager = [[ShortMatchManager alloc] init];
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

/**
 *  MARK:--------------------行为输出转输入--------------------
 *  @version
 *      20200414 - 将输出参数集value_ps转到ThinkIn,去进行识别,保留ShortMatchModel,内类比等流程;
 */
-(void) commitOutputLog:(NSArray*)outputModels{
    //1. 数据
    NSMutableArray *value_ps = [[NSMutableArray alloc] init];
    for (OutputModel *model in ARRTOOK(outputModels)) {
        //2. 装箱
        AIKVPointer *output_p = [theNet getOutputIndex:model.identify outputObj:model.data];
        if (output_p) {
            [value_ps addObject:output_p];
        }
        
        //4. 记录可输出canout (当前善未形成node,所以无法建议索引;(检查一下,当outLog形成node后,索引的建立))
        [AINetUtils setCanOutput:model.identify];
    }
    
    //5. 提交到ThinkIn进行识别;
    [self.thinkIn dataInFromOutput:value_ps];
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
-(void) aiThinkIn_AddToShortMemory:(NSArray*)algNode_ps isMatch:(BOOL)isMatch{
    [self.shortMemory addToShortCache_Ps:algNode_ps isMatch:isMatch];
}

-(NSArray*) aiThinkIn_GetShortMemory:(BOOL)isMatch{
    return [self.shortMemory shortCache:isMatch];
}

-(AIFrontOrderNode*)aiThinkIn_CreateCMVModel:(NSArray *)algsArr isMatch:(BOOL)isMatch{
    AIFrontOrderNode *foNode = [theNet createCMV:algsArr order:[self.shortMemory shortCache:isMatch]];
    
    //20200120 瞬时记忆改为不清空,为解决外层死循环问题 (因为外层循环需要行为输出后,将时序连起来) 参考n18p5-BUG9
    //[self.shortMemory clear];
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
                MVDirection havDemand = [ThinkingUtils havDemand:algsType delta:delta];
                if (havDemand == MVDirection_None) {
                    NSLog(@"STEPKEY当前,预测mv未形成需求:%@ %ld",algsType,delta);
                }
            }
        }
    }
    
    //2. 加上活跃度
    [self updateEnergy:urgentTo];
    
    //3. 将shortMatch保留 (供TOR或TIP调用);
    [self.shortMatchManager add:shortMatchModel];
    
    //4. 激活dataOut
    [self.tOP dataOut];
}
-(void) aiThinkIn_UpdateEnergy:(CGFloat)delta{
    [self updateEnergy:delta];
}
-(BOOL) aiThinkIn_EnergyValid{
    return self.energy > 0;
}
-(NSArray*) aiThinkIn_getShortMatchModel{
    return self.shortMatchManager.models;
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

-(NSArray*) aiTOP_GetShortMatchModel{
    return self.shortMatchManager.models;
}

-(BOOL) aiTOP_Commit2TOR_V2:(NSArray*)curAlg_ps cFo:(AIFoNodeBase*)cFo subNode:(AIFoNodeBase*)subNode plusNode:(AIFoNodeBase*)plusNode{
    return [self.tOR commitFromTOP_Convert2Actions_V2:curAlg_ps cFo:cFo subNode:subNode plusNode:plusNode];
}

-(BOOL) aiTOP_2TOR_ReasonPlus:(AIKVPointer*)cAlg_p cFo:(AIFoNodeBase*)cFo{
    //1. 行为化;
    __block BOOL success = false;
    [self.tOR commitReasonPlus:cAlg_p cFo:cFo complete:^(BOOL actSuccess, NSArray *acts) {
        success = actSuccess;
        
        //2. 更新到outModel;
        if (actSuccess) {
            //[self.demandManager add]; status为尝试输出,事实input发生后,才会移动到下帧;
        }
        
        //3. 输出行为;
        [self.tOR dataOut_ActionScheme:acts];
    }];
    return success;
}

-(BOOL) aiTOP_2TOR_ReasonSub:(AIFoNodeBase *)matchFo plusFo:(AIFoNodeBase *)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase *)checkFo cutIndex:(NSInteger)cutIndex{
    //1. 行为化;
    __block BOOL success = false;
    [self.tOR commitReasonSub:matchFo plusFo:plusFo subFo:subFo checkFo:checkFo cutIndex:cutIndex complete:^(BOOL actSuccess, NSArray *acts) {
        success = actSuccess;
        
        //2. 更新到outModel;
        if (actSuccess) {
            //[self.demandManager add]; status为尝试输出,事实input发生后,才会移动到下帧;
        }
        
        //3. 输出行为;
        [self.tOR dataOut_ActionScheme:acts];
    }];
    return success;
}

-(BOOL) aiTOP_2TOR_PerceptPlus:(AIFoNodeBase *)matchFo{
    //1. 行为化;
    __block BOOL success = false;
    [self.tOR commitPerceptPlus:matchFo complete:^(BOOL actSuccess, NSArray *acts) {
        success = actSuccess;
        
        //2. 更新到outModel;
        if (actSuccess) {
            //[self.demandManager add]; status为尝试输出,事实input发生后,才会移动到下帧;
        }
        
        //3. 输出行为;
        [self.tOR dataOut_ActionScheme:acts];
    }];
    return success;
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
-(AIAlgNodeBase*) aiTOR_MatchRTAlg:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p{
    return [self.thinkIn dataInFromTOR_MatchRTAlg:rtAlg mUniqueV_p:mUniqueV_p];
}
-(AIShortMatchModel*) aiTOR_GetShortMatchModel{
    return ARR_INDEX_REVERSE(self.shortMatchManager.models, 0);
}

@end
