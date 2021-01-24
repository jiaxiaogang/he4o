//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel.h"
#import "AIMatchFoModel.h"

@implementation AIShortMatchModel

-(AIAlgNodeBase *)matchAlg{
    return ARR_INDEX(self.matchAlgs, 0);
}

-(NSMutableArray *)matchFos{
    if (!_matchFos) {
        _matchFos = [[NSMutableArray alloc] init];
    }
    return _matchFos;
}

-(AIFoNodeBase *)matchFo{
    AIMatchFoModel *firstMFo = ARR_INDEX(self.matchFos, 0);
    return firstMFo ? firstMFo.matchFo : nil;
}

-(CGFloat)matchFoValue{
    AIMatchFoModel *firstMFo = ARR_INDEX(self.matchFos, 0);
    return firstMFo ? firstMFo.matchFoValue : 0;
}

-(NSInteger)cutIndex{
    AIMatchFoModel *firstMFo = ARR_INDEX(self.matchFos, 0);
    return firstMFo ? firstMFo.cutIndex : 0;
}

-(TIModelStatus)status{
    AIMatchFoModel *firstMFo = ARR_INDEX(self.matchFos, 0);
    return firstMFo ? firstMFo.status : TIModelStatus_Default;
}

@end
