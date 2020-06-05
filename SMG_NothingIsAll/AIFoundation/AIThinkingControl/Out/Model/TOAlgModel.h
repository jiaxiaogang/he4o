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
 *      1. TOAlgModel在_SP方法中,即尝试了本身的_Hav,也可以尝试其同层节点的_Hav,在失败时,还可以对SP尝试_GL,几种方式有一个达成,即可Finish;
 *      2. 所以在单种方式失败时,要调用下一种方式尝试行为化;
 *      3. 几种方式本身就会竞争,一次只单种,用ScorePK状态,进行方案竞争;
 */
@class TOFoModel;
@interface TOAlgModel : TOModelBase <ITryActionFoDelegate,ISubModelsDelegate>

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(id<ISubModelsDelegate>)group;

/**
 *  MARK:--------------------保留params之cGLDic短记--------------------
 *  @desc 因为TOAction.SP算法执行时,将cGLDic存此,以便其中一个稀疏码成功时,顺利转移下一个;
 */
@property (strong, nonatomic) NSMutableDictionary *cGLDic;


/**
 *  MARK:--------------------保留params之replaceAlgs短记--------------------
 *  @desc 因为TOAction.SP算法执行时,将checkAlg和checkAlg的同层可替代的替身存于此,只要成功一个即可,不过失败时,方便转移;
 */
@property (strong, nonatomic) NSMutableArray *replaceAlgs;

/**
 *  MARK:--------------------pAlg保留--------------------
 *  @desc 在TOAction.SP算法执行时,将pAlg存此,TOValueAlg转移时调用_GL方法会用到;
 */
@property (strong, nonatomic) AIAlgNodeBase *pAlg;

@end
