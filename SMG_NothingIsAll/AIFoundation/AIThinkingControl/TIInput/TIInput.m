//
//  TIInput.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIInput.h"

@implementation TIInput

+(void) rInput:(AIAlgNodeBase*)algNode fromGroup_ps:(NSArray*)fromGroup_ps{
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *mModel = [[AIShortMatchModel alloc] init];
    mModel.protoAlg = algNode;
    mModel.inputTime = [[NSDate date] timeIntervalSince1970];
    
    //2. 识别概念;
    [AIThinkInReason TIR_Alg:algNode.pointer fromGroup_ps:fromGroup_ps complete:^(NSArray *_matchAlgs, NSArray *_partAlg_ps) {
        mModel.matchAlgs = _matchAlgs;
        mModel.partAlg_ps = _partAlg_ps;
    }];
    
    //3. 将mModel保留 (只有先保留后,构建时序时,才会含新帧概念);
    [theTC.inModelManager add:mModel];
    
    //4. 转regroup
    [TIRegroup rRegroup:mModel];
}

+(void) pInput{
    
}

+(void) jump:(TOAlgModel*)algModel{
    [TODemand hDemand:algModel];
}

+(void) feedback{
    //1. 从短时记忆树上,取所有actYes模型,并与新输入的概念做mIsC判断;
}

@end
