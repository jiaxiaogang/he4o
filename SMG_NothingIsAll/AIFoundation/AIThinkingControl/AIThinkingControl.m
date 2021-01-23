//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
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
#import "ReasonDemandModel.h"

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
@interface AIThinkingControl() <AIThinkInDelegate,AIThinkOutPerceptDelegate,AIThinkOutReasonDelegate,DemandManagerDelegate>

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
    self.demandManager = [[DemandManager alloc] init];
    self.demandManager.delegate = self;
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

-(ShortMatchManager*) inModelManager{
    return self.shortMatchManager;
}
-(DemandManager*) outModelManager{
    return self.demandManager;
}

/**
 *  MARK:--------------------活跃度--------------------
 */
-(void) updateEnergy:(CGFloat)delta{
    self.energy = [ThinkingUtils updateEnergy:self.energy delta:delta];
    NSLog(@"inner > delta:%f = energy:%f",delta,self.energy);
}
-(BOOL) energyValid{
    return self.energy > 0;
}

/**
 *  MARK:--------------------AIThinkInDelegate--------------------
 */
-(NSArray*) aiThinkIn_GetShortMemory:(BOOL)isMatch{
    return [self.shortMatchManager shortCache:isMatch];
}

-(AIFrontOrderNode*)aiThinkIn_CreateCMVModel:(NSArray *)algsArr inputTime:(NSTimeInterval)inputTime isMatch:(BOOL)isMatch{
    AIFrontOrderNode *foNode = [theNet createCMV:algsArr inputTime:inputTime order:[self.shortMatchManager shortCache:isMatch]];
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
    
    //2. OPushM
    [AIThinkOutPercept top_OPushM:cmvNode];
    
    //2. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [self updateEnergy:urgentTo];//190730前:((urgentTo + 9)/10) 190730:urgentTo
    [self.demandManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    [self.tOP dataOut];
}

/**
 *  MARK:--------------------提交InModel短时处理--------------------
 *  @version
 *      2020.10.19: 将add至ShortMatchManager代码前迁;
 */
-(void) aiThinkIn_Commit2TC:(AIShortMatchModel*)inModel {
    //1. 数据检查
    if (!inModel) return;
    
    //2. 预测处理_把mv加入到demandManager;
    if (inModel.matchFo) {
        NSInteger urgentTo = 0;
        AIFoNodeBase *matchFo = inModel.matchFo;
        
        //1> 判断matchingFo.mv有值才加入demandManager,同台竞争,执行顺应mv;
        AICMVNodeBase *mvNode = [SMGUtils searchNode:matchFo.cmvNode_p];
        if (mvNode) {
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            if (delta != 0) {
                NSString *algsType = mvNode.urgentTo_p.algsType;
                
                //2> 判断matchValue的匹配度,对mv的迫切度产生"正相关"影响;
                urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
                urgentTo = (int)(urgentTo * inModel.matchFoValue);
                
                //3> 将mv加入demandCache
                [self.demandManager updateCMVCache_RMV:algsType urgentTo:urgentTo delta:delta inModel:inModel];
                
                //4> RMV无需求时;
                MVDirection havDemand = [ThinkingUtils havDemand:algsType delta:delta];
                if (havDemand == MVDirection_None) {
                    NSLog(@"当前,预测mv未形成需求:%@ %ld",algsType,(long)delta);
                }
            }
        }
    }
    
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功;
    DemandModel *demand = [self.demandManager getCurrentDemand];
    
    //5. 外循环入->推进->中循环出;
    BOOL pushOldDemand = [self.tOR tor_OPushM:demand latestMModel:inModel];
    
    //6. 此处推进不成功,则运行TOP四模式;
    if (!pushOldDemand) {
        [self.tOP dataOut];
    }
}
-(NSArray*) aiThinkIn_getShortMatchModel{
    return self.shortMatchManager.models;
}
-(void) aiThinkIn_addShortMatchModel:(AIShortMatchModel*)newMModel{
    [self.shortMatchManager add:newMModel];
}


/**
 *  MARK:--------------------AIThinkOutPerceptDelegate--------------------
 */
-(DemandModel*) aiThinkOutPercept_GetCanDecisionDemand{
    return [self.demandManager getCanDecisionDemand];
}

-(void) aiThinkOutPercept_MVSchemeFailure{
    [self.tOR commitFromTOP_ReflexOut];
}

-(NSArray*) aiTOP_GetShortMatchModel{
    return self.shortMatchManager.models;
}

-(void) aiTOP_2TOR_ReasonPlus:(TOFoModel*)outModel mModel:(AIShortMatchModel*)mModel{
    //1. 行为化;
    [self.tOR commitReasonPlus:outModel mModel:mModel];
}

-(void) aiTOP_2TOR_ReasonSub:(TOFoModel*)foModel demand:(ReasonDemandModel*)demand{
    //1. 行为化;
    [self.tOR commitReasonSub:foModel demand:demand];
}

-(void) aiTOP_2TOR_PerceptSub:(TOFoModel *)outModel{
    //1. 行为化;
    [self.tOR commitPerceptSub:outModel];
}

-(BOOL) aiTOP_2TOR_PerceptPlus:(AIFoNodeBase *)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo{
    //1. 行为化;
    __block BOOL success = false;
    [self.tOR commitPerceptPlus:matchFo plusFo:plusFo subFo:subFo checkFo:checkFo complete:^(BOOL actSuccess, NSArray *acts) {
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
    return [self energyValid];
}
-(AIShortMatchModel*) aiTOR_GetShortMatchModel{
    return ARR_INDEX_REVERSE(self.shortMatchManager.models, 0);
}
-(AIShortMatchModel*) aiTOR_RethinkInnerFo:(AIFoNodeBase*)fo{
    return [self.thinkIn dataInFromTORInnerFo:fo];
}
-(void) aiTOR_MoveForDemand:(DemandModel*)demand{
    [self.tOP commitFromTOR_MoveForDemand:demand];
}

/**
 *  MARK:--------------------DemandManagerDelegate--------------------
 */
-(void)demandManager_updateEnergy:(CGFloat)urgentTo{
    [self updateEnergy:urgentTo];
}

@end
