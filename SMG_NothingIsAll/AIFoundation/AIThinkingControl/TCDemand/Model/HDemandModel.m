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
    //2024.08.05: 避免它成了OuterBack后,又被改回WithOut状态: 只有targetAlg不是OuterBack"已反馈成功"状态时,才可以向父和兄传染WithOut"无解"状态 (参考32142-TODO2);
    TOAlgModel *targetAlg = (TOAlgModel*)self.baseOrGroup;
    if (targetAlg.status == TOModelStatus_OuterBack) return;//其实这个也没啥效果,在hSolution执行发现无解前,就已经有反馈了?这不太可能这么快就发生反馈;
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
