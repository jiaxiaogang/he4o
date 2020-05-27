//
//  TOFoModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "ISubModelsDelegate.h"

/**
 *  MARK:--------------------决策中的时序模型--------------------
 *  1. content_p : 存AIFoNodeBase_p
 *  2. 再通过algScheme联想把具象可执行的具体任务存到memOrder;
 *  3. 其间,如果有执行失败,无效等概念节点,存到except_ps不应期;
 *  4. 不应期会上报给上一级except_ps (或许由TOModelStatus来替代此功能);
 */
@interface TOFoModel : TOModelBase <ISubModelsDelegate>

@property (strong, nonatomic) NSMutableArray *actions;//行为化数据;

@property (strong, nonatomic) AIFoNodeBase *fo;                     //对应的fo节点

/**
 *  MARK:--------------------当前正在行为化的下标--------------------
 *  @todo 将actionIndex赋值,改为生成TOAlgModel模型,并挂在subModels下;
 */
@property (assign, nonatomic) NSInteger actionIndex;
//@property (strong, nonatomic) NSMutableDictionary *itemSubModels;   //每个下标,对应的subModels字典;


/**
 *  MARK:--------------------当前正在激活中的subModel--------------------
 *  可由status来替代此功能 (status可支持多个激活状态的fo);
 */
@property (strong, nonatomic) TOModelBase *activateSubModel;


/**
 *  MARK:--------------------当前model的状态--------------------
 */
@property (assign, nonatomic) TOModelStatus status;

@end
