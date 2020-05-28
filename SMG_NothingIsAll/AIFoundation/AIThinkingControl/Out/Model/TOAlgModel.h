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

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p parent:(TOFoModel*)parent;

@end
