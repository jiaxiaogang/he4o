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
@class AISceneModel,AITransferModel,TCTransferXvModel,AIRealModel;
@interface TOFoModel : TOModelBase <ISubModelsDelegate,ISubDemandDelegate,NSCoding>

/**
 *  MARK:--------------------newWith--------------------
 *  @desc
 *      1. R任务时,backMatchValue和targetIndex两个参数无用;
 *      2. H任务时,所有参数都有效;
 */
+(TOFoModel*) newWithCansetFo:(AIKVPointer*)cansetFo sceneFo:(AIKVPointer*)sceneFo base:(TOModelBase<ITryActionFoDelegate>*)base
           protoFrontIndexDic:(NSDictionary *)protoFrontIndexDic matchFrontIndexDic:(NSDictionary *)matchFrontIndexDic
              frontMatchValue:(CGFloat)frontMatchValue frontStrongValue:(CGFloat)frontStrongValue
               midEffectScore:(CGFloat)midEffectScore midStableScore:(CGFloat)midStableScore
                 backIndexDic:(NSDictionary*)backIndexDic backMatchValue:(CGFloat)backMatchValue backStrongValue:(CGFloat)backStrongValue
               cansetCutIndex:(NSInteger)cansetCutIndex sceneCutIndex:(NSInteger)sceneCutIndex
                  targetIndex:(NSInteger)targetIndex sceneTargetIndex:(NSInteger)sceneTargetIndex
       basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel baseSceneModel:(AISceneModel*)baseSceneModel;

+(TOFoModel*) newForHCansetFo:(AIKVPointer*)canset sceneFo:(AIKVPointer*)scene base:(TOModelBase<ITryActionFoDelegate>*)base
               cansetCutIndex:(NSInteger)cutIndex sceneCutIndex:(NSInteger)sceneCutIndex
            cansetTargetIndex:(NSInteger)targetIndex sceneTargetIndex:(NSInteger)sceneTargetIndex
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

/**
 *  MARK:--------------------最终反馈的protoMv--------------------
 *  @desc 当前fo的目标为mv时,如果反馈了mv,即记录到此处 (可用于生成实际发生protoFo时用到);
 */
@property (strong, nonatomic) AIKVPointer *feedbackMv;

/**
 *  MARK:--------------------反思未通过标记--------------------
 */
@property (assign, nonatomic) BOOL refrectionNo;

/**
 *  MARK:--------------------将每帧反馈转成orders,以构建protoFo--------------------
 */
-(NSArray*) getOrderUseMatchAndFeedbackAlg:(BOOL)fromRegroup;

/**
 *  MARK:--------------------算出新的indexDic--------------------
 */
-(NSDictionary*) convertOldIndexDic2NewIndexDic:(AIKVPointer*)targetOrPFo_p;

/**
 *  MARK:--------------------算出新的spDic--------------------
 */
-(NSDictionary*) convertOldSPDic2NewSPDic;

/**
 *  MARK:--------------------返回需用于反省或有效统计的cansets (参考29069-todo11 && todo11.2)--------------------
 */
-(NSArray*) getRethinkEffectCansets;


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

/**
 *  MARK:--------------------从决策中一步步传过来 (参考29069-todo7)--------------------
 *  @desc 无论是R还是H,它的baseSceneModel都是rSceneModel;
 */
@property (strong, nonatomic) AISceneModel *baseSceneModel;

//MARK:===============================================================
//MARK:                     < 前段部分 >
//MARK:===============================================================

@property (strong, nonatomic) NSDictionary *protoFrontIndexDic;//前段canset与proto的映射字典 (canset是抽象);
@property (strong, nonatomic) NSDictionary *matchFrontIndexDic;//前段canset与scene的映射字典 (scene是抽象);

/**
 *  MARK:--------------------前段匹配度--------------------
 *  @desc 目前其表示cansetFo与protoFo的前段匹配度;
 *  @version
 *      2023.01.13: 求乘版: 用canset前段和match的帧映射计算前段匹配度 (参考28035-todo3);
 *      2023.02.18: AIRank细分版: 用canset前段和proto的帧映射计算前段匹配度 (参考28083-方案2);
 */
@property (assign, nonatomic) CGFloat frontMatchValue;

/**
 *  MARK:--------------------前段强度竞争值 (参考28083-方案2)--------------------
 *  @desc cansetFo的前段部分的refStrong平均强度;
 */
@property (assign, nonatomic) CGFloat frontStrongValue;


//MARK:===============================================================
//MARK:                     < 后段部分 >
//MARK:===============================================================
@property (assign, nonatomic) CGFloat backMatchValue;   //后段匹配度 (R时为1,H时为目标帧相近度) (参考28092-todo1);
@property (assign, nonatomic) CGFloat backStrongValue;  //后段强度值 (R时为0,H时为目标帧conStrong强度) (参考28092-todo2);
@property (strong, nonatomic) NSDictionary *backIndexDic;//后段canset与match的映射字典 (match是抽象);

@property (assign, nonatomic) CGFloat midStableScore;    //中段稳定性分;
@property (assign, nonatomic) CGFloat midEffectScore;    //整体有效率分;

/**
 *  MARK:--------------------cansetFo已发生截点--------------------
 *  @todo 将cutIndex赋值,改为生成TOAlgModel模型,并挂在subModels下;
 *  @desc cutIndex表示当前从执行到执行下帧前 (即cutIndex一般表示已执行 / 含cutIndex也已发生);
 */
@property (assign, nonatomic) NSInteger cansetCutIndex;

/**
 *  MARK:--------------------执行目标index--------------------
 *  @desc foModel要行为化的index目标 (默认目标为mv_即全执行);
 *      1. 如全执行完,则是为了mv结果;
 *      2. 如执行到某一帧,则是为了实现HDemand;
 *      3. 注: 其中要执行的不包括targetIndex,比如为1时,则目标为1,只执行到0(第1帧),为content.count时,则目标为mv;
 */
@property (assign, nonatomic) NSInteger targetIndex;    //cansetFo执行目标index (R时为fo.count,H时为目标帧下标);
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
-(void) commit4FeedbackTOR:(NSArray*)feedbackMatchAlg_ps protoAlg:(AIKVPointer*)protoAlg_p;

/**
 *  MARK:--------------------方案状态--------------------
 */
@property (assign, nonatomic) CansetStatus cansetStatus;

/**
 *  MARK:--------------------此方案是用于什么任务 (true=H false=R)--------------------
 */
-(BOOL) isH;

/**
 *  MARK:--------------------取此方案迁移目标--------------------
 */
-(AIKVPointer*) sceneTo;

/**
 *  MARK:--------------------实际反馈记录--------------------
 */
@property (strong, nonatomic) AIRealModel *realModel;

@end
