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
 */
@class TOFoModel;
@interface TOAlgModel : TOModelBase <ITryActionFoDelegate,ISubModelsDelegate>

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p parent:(id<ISubModelsDelegate>)parent;

/**
 *  MARK:--------------------cGLDic短记--------------------
 *  @desc 因为TOAction.SP算法执行时,将cGLDic存此,以便其中一个稀疏码成功时,顺利转移下一个;
 */
@property (strong, nonatomic) NSMutableDictionary *cGLDic;

/**
 *  MARK:--------------------pAlg保留--------------------
 *  @desc 在TOAction.SP算法执行时,将pAlg存此,TOValueAlg转移时调用_GL方法会用到;
 */
@property (strong, nonatomic) AIAlgNodeBase *pAlg;

@end
