//
//  TOValueModel.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/28.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "ITryActionFoDelegate.h"

/**
 *  MARK:--------------------决策中的稀疏码模型--------------------
 */
@class TOAlgModel;
@interface TOValueModel : TOModelBase <ITryActionFoDelegate>

@property (strong, nonatomic) AIKVPointer *sValue_p;
+(TOValueModel*) newWithSValue:(AIKVPointer*)sValue_p pValue:(AIKVPointer*)pValue_p group:(TOAlgModel*)group;

@end
