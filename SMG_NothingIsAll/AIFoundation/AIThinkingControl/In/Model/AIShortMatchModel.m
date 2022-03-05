//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel.h"

@implementation AIShortMatchModel

-(AIAlgNodeBase *)matchAlg{
    return ARR_INDEX(self.matchAlgs, 0);
}

-(NSMutableArray *)matchPFos{
    if (!_matchPFos) _matchPFos = [[NSMutableArray alloc] init];
    return _matchPFos;
}

-(NSMutableArray *)matchRFos{
    if (!_matchRFos) _matchRFos = [[NSMutableArray alloc] init];
    return _matchRFos;
}

//-(AIFoNodeBase *)matchFo{
//    AIMatchFoModel *mFo = [self mustUrgentMFo];
//    return mFo ? mFo.matchFo : nil;
//}

//-(CGFloat)matchFoValue{
//    AIMatchFoModel *mFo = [self mustUrgentMFo];
//    return mFo ? mFo.matchFoValue : 0;
//}

//-(TIModelStatus)status{
//    AIMatchFoModel *mFo = [self mustUrgentMFo];
//    return mFo ? mFo.status : TIModelStatus_Default;
//}

/**
 *  MARK:--------------------取最迫切的matchFoModel--------------------
 *  @desc 即是评分<0,且最小的那个;
 */
//-(AIMatchFoModel*) mustUrgentMFo{
//    //1. 找出最迫切的;
//    AIMatchFoModel *result;
//    for (AIMatchFoModel *item in self.matchPFos) {
//
//        //2. 首个只要是有迫切度即可;
//        CGFloat newScore = [AIScore score4MV:item.matchFo.cmvNode_p ratio:item.matchFoValue];
//        if (!result && newScore < 0) result = item;
//
//        //3. 将更迫切的替换到result;
//        CGFloat oldScore = [AIScore score4MV:result.matchFo.cmvNode_p ratio:result.matchFoValue];
//        if (newScore < oldScore) {
//            result = item;
//        }
//    }
//    return result;
//}


//MARK:===============================================================
//MARK:           < 不同用途时取不同prFos (参考25134-方案2) >
//MARK:===============================================================

//用于学习 (参考:25134-方案2-A学习);
-(NSArray*) fos4RLearning{
    return [SMGUtils collectArrA:[AIShortMatchModel fullMatchs:self.matchPFos] arrB:[AIShortMatchModel fullMatchs:self.matchRFos]];
}
-(NSArray*) fos4PLearning{
    return ARR_SUB(self.matchPFos, 0, 10);
}

//用于预测 (参考:25134-方案2-B预测);
-(NSArray*) fos4RForecast{
    return [SMGUtils collectArrA:[AIShortMatchModel partMatchs:self.matchPFos] arrB:[AIShortMatchModel partMatchs:self.matchRFos]];
}
-(NSArray*) fos4PForecast{
    return [AIShortMatchModel fullMatchs:self.matchPFos];
}

//用于需求 (参考:25134-方案2-C需求);
-(NSArray*) fos4Demand{
    return ARR_SUB(self.matchPFos, 0, 10);
}

//MARK:===============================================================
//MARK:                     < 筛选全含与非全含的fos >
//MARK:===============================================================

/**
 *  MARK:--------------------筛选出全含的--------------------
 *  @desc 排序: 全含,以时序长度排序;
 */
+(NSArray*) fullMatchs:(NSArray*)matchs {
    //1. 筛选;
    NSArray *fullMatchs = [SMGUtils filterArr:matchs checkValid:^BOOL(AIMatchFoModel *item) {
        return item.matchFoValue > 0.99f;
    }];
    
    //2. 排序;
    fullMatchs = [fullMatchs sortedArrayUsingComparator:^NSComparisonResult(AIMatchFoModel *o1, AIMatchFoModel *o2) {
        return [SMGUtils compareIntA:o1.matchFo.count intB:o2.matchFo.count];
    }];
    
    //3. 返10条;
    return ARR_SUB(fullMatchs, 0, 10);
}

/**
 *  MARK:--------------------筛选出非全含的--------------------
 *  @desc 排序: 非全含,以匹配度(默认)排序;
 */
+(NSArray*) partMatchs:(NSArray*)matchs {
    //1. 筛选;
    NSArray *partMatchs = [SMGUtils filterArr:matchs checkValid:^BOOL(AIMatchFoModel *item) {
        return item.matchFoValue < 0.99f;
    }];
    
    //2. 返10条;
    return ARR_SUB(partMatchs, 0, 10);
}

@end
