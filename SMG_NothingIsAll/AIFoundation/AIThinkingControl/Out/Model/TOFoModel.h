//
//  TOFoModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "ISubModelsDelegate.h"
#import "ITryActionFoDelegate.h"
#import "ISubDemandDelegate.h"

/**
 *  MARK:--------------------决策中的时序模型--------------------
 *  @desc 含: 单条S候选集与proto对比结果模型;
 *  @desc 作用:
 *      1. 主要作用是用于TCSolution竞争值和做竞争用;
 *      2. 次要作用是参数传递: fromAISceneModel -> toTOFoModel;
 *  1. content_p : 存AIFoNodeBase_p
 *  2. 再通过algScheme联想把具象可执行的具体任务存到memOrder;
 *  3. 其间,如果有执行失败,无效等概念节点,存到except_ps不应期;
 *  4. 不应期会上报给上一级except_ps (或许由TOModelStatus来替代此功能);
 *  @version
 *      2021.03.27: 实现ITryActionFoDelegate接口,因为每个fo都有可能是子任务 (参考22193);
 */
@class AISceneModel,AITransferModel,TCTransferXvModel;
@interface TOFoModel : TOModelBase <ISubModelsDelegate,ISubDemandDelegate,NSCoding>

+(TOFoModel*) newForRCansetFo:(AIKVPointer*)cansetFrom_p sceneFrom:(AIKVPointer*)sceneFrom_p
                         base:(TOModelBase<ITryActionFoDelegate>*)base basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel baseSceneModel:(AISceneModel*)baseSceneModel
                sceneCutIndex:(NSInteger)sceneCutIndex cansetCutIndex:(NSInteger)cansetCutIndex
            cansetTargetIndex:(NSInteger)cansetTargetIndex sceneFromTargetIndex:(NSInteger)sceneFromTargetIndex;

+(TOFoModel*) newForHCansetFo:(AIKVPointer*)canset sceneFo:(AIKVPointer*)scene base:(TOModelBase<ITryActionFoDelegate>*)base
               cansetCutIndex:(NSInteger)cutIndex sceneCutIndex:(NSInteger)sceneCutIndex
            cansetTargetIndex:(NSInteger)cansetTargetIndex sceneTargetIndex:(NSInteger)sceneTargetIndex
       basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel baseSceneModel:(AISceneModel*)baseSceneModel;

/**
 *  MARK:--------------------行为化数据--------------------
 *  @version
 *      2020.08.27: 将actions行为化数据字段去掉,因为现在行为化数据在每一个isOut=true的TOAlgModel中;
 */
//@property (strong, nonatomic) NSMutableArray *actions;

//@property (strong, nonatomic) NSMutableDictionary *itemSubModels;   //每个下标,对应的subModels字典;


/**
 *  MARK:--------------------当前正在激活中的subModel--------------------
 *  可由status来替代此功能 (status可支持多个激活状态的fo);
 */
//@property (strong, nonatomic) TOModelBase *activateSubModel;

//MARK:===============================================================
//MARK:                     < feedbackMv部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------最终反馈的protoMv--------------------
 *  @desc 当前fo的目标为mv时,如果反馈了mv,即记录到此处 (可用于生成实际发生protoFo时用到);
 */
@property (strong, nonatomic) AIKVPointer *feedbackMv;
-(BOOL) feedbackMvAndPlus;
-(BOOL) feedbackMvAndSub;

/**
 *  MARK:--------------------反思未通过标记--------------------
 */
@property (assign, nonatomic) BOOL refrectionNo;

/**
 *  MARK:--------------------将每帧反馈转成orders,以构建protoFo--------------------
 */
-(NSArray*) getOrderUseMatchAndFeedbackAlg:(BOOL)fromRegroup;


//MARK:===============================================================
//MARK:                     < CansetModel >
//MARK:===============================================================
@property (strong, nonatomic) AIKVPointer *cansetFo;    //迁移前候选集fo;
@property (strong, nonatomic) AIKVPointer *sceneFo;     //迁移前候选集所在的scene

/**
 *  MARK:--------------------此解决方案基于哪个pFo/targetFo--------------------
 *  @desc R任务时为pFoModel,H任务时为targetFoModel;
 *  @callers:
 *      1. 用于构建TOFoModel时,传过去;
 */
@property (strong, nonatomic) id basePFoOrTargetFoModel;
-(AIMatchFoModel*) basePFo;//递归取basePFo;

/**
 *  MARK:--------------------从决策中一步步传过来 (参考29069-todo7)--------------------
 *  @desc 无论是R还是H,它的baseSceneModel都是rSceneModel;
 */
@property (strong, nonatomic) AISceneModel *baseSceneModel;

/**
 *  MARK:--------------------cansetFo已发生截点--------------------
 *  @todo 将cutIndex赋值,改为生成TOAlgModel模型,并挂在subModels下;
 *  @desc cutIndex表示当前从执行到执行下帧前 (即cutIndex一般表示已执行 / 含cutIndex也已发生);
 */
@property (assign, nonatomic) NSInteger cansetCutIndex;
- (NSInteger)cansetActIndex;//行为化中截点 = cansetCutIndex+1
@property (assign, nonatomic) NSInteger initCansetCutIndex;//初始化时的截点

/**
 *  MARK:--------------------执行目标index--------------------
 *  @desc foModel要行为化的index目标 (默认目标为mv_即全执行);
 *      1. 如全执行完,则是为了mv结果;
 *      2. 如执行到某一帧,则是为了实现HDemand;
 *      3. 注: 其中要执行的不包括cansetTargetIndex,比如为1时,则目标为1,只执行到0(第1帧),为content.count时,则目标为mv;
 */
@property (assign, nonatomic) NSInteger cansetTargetIndex;    //cansetFo执行目标index (R时为fo.count,H时为目标帧下标);
@property (assign, nonatomic) NSInteger sceneCutIndex;  //sceneFo已发生截点 (含cutIndex也已发生);
@property (assign, nonatomic) NSInteger sceneTargetIndex;//sceneFo任务目标index (R时为fo.count,H时为目标帧下标);

/**
 *  MARK:--------------------虚实v2模型--------------------
 */
@property (strong, nonatomic) TCTransferXvModel *transferXvModel;
@property (strong, nonatomic) AITransferModel *transferSiModel;

/**
 *  MARK:--------------------下帧初始化 (可接受反馈) (参考31073-TODO2g)--------------------
 */
-(void) pushNextFrame;

/**
 *  MARK:--------------------获取当前正在推进中的帧--------------------
 */
-(TOAlgModel*) getCurFrame;

/**
 *  MARK:--------------------feedbackTOR反馈时触发,用于每个cansetFo都可以接受持续反馈推进--------------------
 */
-(BOOL) commit4FeedbackTOR:(NSArray*)feedbackMatchAlg_ps protoAlg:(AIKVPointer*)protoAlg_p except4SP2F:(NSMutableArray*)except4SP2F;

/**
 *  MARK:--------------------方案状态--------------------
 */
@property (assign, nonatomic) CansetStatus cansetStatus;
@property (assign, nonatomic) BOOL isInfected;//已传染 (因帧条件未满足被传染,在激活前就被提前淘汰掉)

/**
 *  MARK:--------------------此方案是用于什么任务 (true=H false=R)--------------------
 */
-(BOOL) isH;

/**
 *  MARK:--------------------迁移源--------------------
 */
-(AIKVPointer*) sceneFrom;
-(AIKVPointer*) cansetFrom;

/**
 *  MARK:--------------------取此方案迁移目标--------------------
 */
-(AIKVPointer*) sceneTo;
-(AIKVPointer*) cansetTo;

/**
 *  MARK:--------------------实际与场景之间的映射--------------------
 *  @desc 场景表示当前的cansetTo & 实际发生表示pFo.realMaskFo;
 *  @desc 用于记录实际反馈与cansetTo的映射 (每反馈一帧,记录一帧) <K:场景 V:实际>;
 */
@property (strong, nonatomic) NSMutableDictionary *realCansetToIndexDic;
-(void) initRealCansetToDic;    //初始化已发生映射;
-(void) fixRealCansteToDic;     //补上前段层层传递错漏的映射;
-(void) updateRealCansetToDic;  //更新反馈匹配映射;

//Action已经执行过了ActIndex (默认为-1);
@property (assign, nonatomic) NSInteger alreadyActionActIndex;

/**
 *  MARK:--------------------检查更新OutSPDic强度值--------------------
 */
-(void) checkAndUpdateOutSPStrong_Reason:(NSInteger)difStrong type:(AnalogyType)type debugMode:(BOOL)debugMode caller:(NSString*)caller except4SP2F:(NSMutableArray*)except4SP2F;
-(void) checkAndUpdateOutSPStrong_Percept:(NSInteger)difStrong type:(AnalogyType)type debugMode:(BOOL)debugMode caller:(NSString*)caller except4SP2F:(NSMutableArray*)except4SP2F;

/**
 *  MARK:--------------------取outSPDic (转实前取cansetFrom的,转实后取cansetTo的) (参考33062-正据4&TODO5)--------------------
 */
-(NSMutableDictionary*) getItemOutSPDic;

@end
