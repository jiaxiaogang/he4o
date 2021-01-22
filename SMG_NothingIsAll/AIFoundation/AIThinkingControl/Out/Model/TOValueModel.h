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

/**
 *  MARK:--------------------现值留存--------------------
 */
@property (strong, nonatomic) AIKVPointer *sValue_p;

/**
 *  MARK:--------------------ValueModel--------------------
 *  @param sValue_p : 现值留存;
 *  @param pValue_p : 为当前content_p,同时也是本次GL加工目标;
 */
+(TOValueModel*) newWithSValue:(AIKVPointer*)sValue_p pValue:(AIKVPointer*)pValue_p group:(TOAlgModel*)group;

@end
