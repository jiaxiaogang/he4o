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
#import "AIThinkOut.h"
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
@interface AIThinkingControl() <AIThinkInDelegate>

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
    self.demandManager = [[DemandManager alloc] init];
    self.thinkIn = [[AIThinkIn alloc] init];
    self.thinkIn.delegate = self;
    self.thinkOut = [[AIThinkOut alloc] init];
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

-(AIShortMatchModel *)to_Rethink:(TOFoModel*)toFoModel{
    return [self.thinkIn dataInFromRethink:toFoModel];
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
    [self.demandManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    [self.thinkOut dataOut];
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
    [self.demandManager updateCMVCache_RMV:inModel];
    
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功;
    DemandModel *demand = [self.demandManager getCurrentDemand];
    
    //5. 外循环入->推进->中循环出;
    BOOL pushOldDemand = [self.thinkOut.tOR tor_OPushM:demand latestMModel:inModel];
    
    //6. 此处推进不成功,则运行TOP四模式;
    if (!pushOldDemand) {
        [self.thinkOut dataOut];
    }
}
-(NSArray*) aiThinkIn_getShortMatchModel{
    return self.shortMatchManager.models;
}
-(void) aiThinkIn_addShortMatchModel:(AIShortMatchModel*)newMModel{
    [self.shortMatchManager add:newMModel];
}

@end
