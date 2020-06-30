//
//  TOInputAlgModel.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/6/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "ITryActionFoDelegate.h"
#import "ISubModelsDelegate.h"

/**
 *  MARK:--------------------决策中的概念模型->Input版--------------------
 *  @desc
 *      1. 说明: 将新输入的protoAlg与matchAlg进行比较,理性评价,从而对稀疏码特征进行修正;
 *      2. 比如: 吃瓜子,得到带皮瓜子,就得先去皮再吃;
 */
@class TOFoModel;
@interface TOInputAlgModel : TOModelBase <ITryActionFoDelegate,ISubModelsDelegate>

+(TOInputAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(id<ISubModelsDelegate>)group;

//第三步行为化,对alg进行理性评价 (稀疏码检查);
@property (strong, nonatomic) NSMutableArray *justPValues;
@property (strong, nonatomic) AIAlgNodeBase *protoAlg;

@end
