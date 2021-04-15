//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel.h"
#import "AIMatchFoModel.h"
#import "AIScore.h"

@implementation AIShortMatchModel

-(AIAlgNodeBase *)matchAlg{
    return ARR_INDEX(self.matchAlgs, 0);
}

-(NSMutableArray *)matchPFos{
    if (!_matchPFos) {
        _matchPFos = [[NSMutableArray alloc] init];
    }
    return _matchPFos;
}

-(NSMutableArray *)matchRFos{
    if (!_matchRFos) {
        _matchRFos = [[NSMutableArray alloc] init];
    }
    return _matchRFos;
}

-(AIFoNodeBase *)matchFo{
    AIMatchFoModel *mFo = [self mustUrgentMFo];
    return mFo ? mFo.matchFo : nil;
}

-(CGFloat)matchFoValue{
    AIMatchFoModel *mFo = [self mustUrgentMFo];
    return mFo ? mFo.matchFoValue : 0;
}

-(NSInteger)cutIndex{
    AIMatchFoModel *mFo = [self mustUrgentMFo];
    return mFo ? mFo.cutIndex : 0;
}

-(TIModelStatus)status{
    AIMatchFoModel *mFo = [self mustUrgentMFo];
    return mFo ? mFo.status : TIModelStatus_Default;
}

/**
 *  MARK:--------------------取最迫切的matchFoModel--------------------
 *  @desc 即是评分<0,且最小的那个;
 */
-(AIMatchFoModel*) mustUrgentMFo{
    //1. 找出最迫切的;
    AIMatchFoModel *result;
    for (AIMatchFoModel *item in self.matchPFos) {
        
        //2. 首个只要是有迫切度即可;
        CGFloat newScore = [AIScore score4MV:item.matchFo.cmvNode_p ratio:item.matchFoValue];
        if (!result && newScore < 0) result = item;
        
        //3. 将更迫切的替换到result;
        CGFloat oldScore = [AIScore score4MV:result.matchFo.cmvNode_p ratio:result.matchFoValue];
        if (newScore < oldScore) {
            result = item;
        }
    }
    return result;
}

@end
