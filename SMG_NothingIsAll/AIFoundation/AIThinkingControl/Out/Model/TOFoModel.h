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
 *  1. content_p : 存AIFoNodeBase_p
 *  2. 再通过algScheme联想把具象可执行的具体任务存到memOrder;
 *  3. 其间,如果有执行失败,无效等概念节点,存到except_ps不应期;
 *  4. 不应期会上报给上一级except_ps (或许由TOModelStatus来替代此功能);
 *  @version
 *      2021.03.27: 实现ITryActionFoDelegate接口,因为每个fo都有可能是子任务 (参考22193);
 */
@interface TOFoModel : TOModelBase <ISubModelsDelegate,ISubDemandDelegate>

+(TOFoModel*) newWithFo_p:(AIKVPointer*)fo_p base:(TOModelBase<ITryActionFoDelegate>*)base basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel;

/**
 *  MARK:--------------------行为化数据--------------------
 *  @version
 *      2020.08.27: 将actions行为化数据字段去掉,因为现在行为化数据在每一个isOut=true的TOAlgModel中;
 */
//@property (strong, nonatomic) NSMutableArray *actions;

/**
 *  MARK:--------------------当前正在行为化的下标--------------------
 *  @todo 将actionIndex赋值,改为生成TOAlgModel模型,并挂在subModels下;
 *  @desc actionIndex表示当前从执行到执行下帧前 (即actionIndex一般表示已执行);
 */
@property (assign, nonatomic) NSInteger actionIndex;

/**
 *  MARK:--------------------执行目标index--------------------
 *  @desc foModel要行为化的index目标 (默认目标为mv_即全执行);
 *      1. 如全执行完,则是为了mv结果;
 *      2. 如执行到某一帧,则是为了实现HDemand;
 *      3. 注: 其中要执行的不包括targetIndex,比如为1时,则目标为1,只执行到0(第1帧),为content.count时,则目标为mv;
 */
@property (assign, nonatomic) NSInteger targetSPIndex;

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
 *  MARK:--------------------此解决方案基于哪个pFo/targetFo--------------------
 */
@property (weak, nonatomic) id basePFoOrTargetFoModel;//R任务时为pFoModel,H任务时为targetFoModel;

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

@end
