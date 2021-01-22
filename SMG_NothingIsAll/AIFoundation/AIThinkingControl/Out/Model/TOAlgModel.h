//
//  TOAlgModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "ITryActionFoDelegate.h"
#import "ISubModelsDelegate.h"

/**
 *  MARK:--------------------决策中的概念模型--------------------
 *  1. 将content_p中的概念进行行为化;
 *  2. content_p : AIAlgNodeBase_p
 *  @相对其它outModel模型特殊说明:
 *      1. TOAlgModel在_SP方法中,即尝试了本身的_Hav,也可以尝试其同层节点的_Hav,在失败时,还可以对SP尝试_GL,几种方式有一个达成,即可Act_Yes;
 *      2.1 所以在单种方式失败时,要调用下一种方式尝试行为化;
 *      2.2 所以在方案(一)的_Hav方式失败时,要调用方案(二)方式尝试GL行为化;
 *      3. 几种方式本身就会竞争,一次只单种,用ScorePK状态,进行方案竞争;
 *      4. 在Act_Yes后,外循环有了结果后,要先进行方案(三)的理性评价,才可以转为Finish;
 */
@class TOFoModel;
@interface TOAlgModel : TOModelBase <ITryActionFoDelegate,ISubModelsDelegate>

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(id<ISubModelsDelegate>)group;

/**
 *  MARK:-------------------- 一: 保留params之replaceAlgs短记--------------------
 *  @desc
 *      1. 因为TOAction.SP算法执行时,将checkAlg和checkAlg的同层可替代的替身存于此,只要成功一个即可,不过失败时,方便转移;
 *      2. 在Action._Hav中,将每一次尝试PM的reModel存于此,下次再执行时,用作不应期,避免死循环;
 */
@property (strong, nonatomic) NSMutableArray *replaceAlgs;

/**
 *  MARK:-------------------- 二: 保留params之cGLDic短记--------------------
 *  @desc 因为TOAction.SP算法执行时,将cGLDic存此,以便其中一个稀疏码成功时,顺利转移下一个;
 */
@property (strong, nonatomic) NSMutableDictionary *cGLDic;
//在TOAction.SP算法执行时,将pAlg存此,TOValueAlg转移时调用_GL方法会用到;
@property (strong, nonatomic) AIAlgNodeBase *sp_P;


/**
 *  MARK:-------------------- 三: 对alg进行理性评价 (稀疏码检查) --------------------
 *  @desc 当一,或者二,转行为化后,外界输入回来,由此处对其进行理性评价;
 *  @desc
 *      1. 说明: 将新输入的protoAlg与matchAlg进行比较,理性评价,从而对稀疏码特征进行修正;
 *      2. 比如: 吃瓜子,得到带皮瓜子,就得先去皮再吃;
 *      3. 在理性评价时,将要用到的MatchAlg就是当前模型中的content_p;
 *      4. 在理性评价时,将要用到的MatchFo就是当前模型中.baseOrGroup中包含的时序;
 */
@property (strong, nonatomic) NSMutableArray *justPValues;
//保留字段 (score用于存M所在matchFo的价值分,mvAT用于存M所在的matchFo的价值at标识);
@property (assign, nonatomic) float pm_Score;
@property (strong, nonatomic) NSString *pm_MVAT;
@property (strong, nonatomic) AIFoNodeBase *pm_Fo;//用来取conPorts的Fo
@property (strong, nonatomic) AIAlgNodeBase *pm_ProtoAlg;//getInnerAlg(GL)时,用作联想参考;

/**
 *  MARK:--------------------实际发生的概念保留--------------------
 *  @desc
 *      1. 在commitFromOuterPushMiddleLoop中进行保留;
 *      2. 在ActYes流程控制中,生物钟触发器触发时,进行使用,用于反省类比;
 */
@property (strong, nonatomic) AIKVPointer *realContent_p;

@end
