//
//  HDemandModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "HDemandModel.h"

@implementation HDemandModel

+(HDemandModel*) newWithAlgModel:(TOAlgModel*)base{
    HDemandModel *result = [[HDemandModel alloc] init];
    result.baseOrGroup = base;
    [base.subDemands addObject:result];
    return result;
}

/**
 *  MARK:--------------------H任务无计可施时调用--------------------
 *  @desc 赋值WithOut后,处理H任务的父级传染和兄弟传染 (参考31073-TODO8b & TODO8c);
 */
-(void) setStatus2WithOut {
    //1. 当前任务WithOut;
    self.status = TOModelStatus_WithOut;
    
    //2. 向父级传染 (参考31073-TODO8b);
    TOAlgModel *targetAlg = (TOAlgModel*)self.baseOrGroup;
    targetAlg.status = TOModelStatus_WithOut;
    TOFoModel *targetFo = (TOFoModel*)targetAlg.baseOrGroup;
    targetFo.status = TOModelStatus_WithOut;
    
    //3. 向兄弟传染: 当前targetFo同一个Cansets池子里的兄弟,如果现在也在等待一模一样的targetAlg,那么全计为失败 (参考31073-TODO8c);
    DemandModel *baseDemand = (DemandModel*)targetFo.baseOrGroup;
    for (TOFoModel *brotherFoModel in baseDemand.actionFoModels) {
        TOAlgModel *brotherAlgModel = brotherFoModel.getCurFrame;
        if ([brotherAlgModel.content_p isEqual:targetAlg.content_p]) {
            brotherAlgModel.status = TOModelStatus_WithOut;
            brotherFoModel.status = TOModelStatus_WithOut;
        }
    }
}

@end
