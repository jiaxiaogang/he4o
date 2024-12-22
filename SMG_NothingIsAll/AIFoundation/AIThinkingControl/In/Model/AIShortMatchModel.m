//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel.h"

@implementation AIShortMatchModel

-(AIMatchAlgModel *)firstMatchAlg{
    return ARR_INDEX(self.matchAlgs_Si, 0);
}

/**
 *  MARK:--------------------取概念识别结果--------------------
 */
-(NSArray*) matchAlgs_R {
    return [SMGUtils collectArrA:self.matchAlgs_RJ arrB:self.matchAlgs_RS];
}

-(NSArray*) matchAlgs_P {
    return [SMGUtils collectArrA:self.matchAlgs_PJ arrB:self.matchAlgs_PS];
}

//返回似层 notnull;
-(NSArray*) matchAlgs_Si {
    //合并PR的似层返回 (参考29108-2.2);
    return [SMGUtils collectArrA:self.matchAlgs_PS arrB:self.matchAlgs_RS];
}

//返回交层 notnull;
-(NSArray*) matchAlgs_Jiao {
    return [SMGUtils collectArrA:self.matchAlgs_PJ arrB:self.matchAlgs_RJ];
}
//返回全部 notnull;
-(NSArray*) matchAlgs_All {
    return [SMGUtils collectArrA:self.matchAlgs_Si arrB:self.matchAlgs_Jiao];
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
//-(NSArray*) fos4RLearning{
//    return [SMGUtils collectArrA:[AIShortMatchModel fullMatchs:self.matchPFos] arrB:[AIShortMatchModel fullMatchs:self.matchRFos]];
//}
-(NSArray*) fos4PLearning{
    return ARR_SUB(self.matchPFos, 0, 10);
}

//用于预测 (参考:25134-方案2-B预测);
//-(NSArray*) fos4RForecast{
//    return [SMGUtils collectArrA:[AIShortMatchModel partMatchs:self.matchPFos] arrB:[AIShortMatchModel partMatchs:self.matchRFos]];
//}
-(NSArray*) fos4PForecast{
    return [AIShortMatchModel fullMatchs:self.matchPFos];
}

/**
 *  MARK:--------------------用于需求--------------------
 *  @version
 *      2022.05.17: pFos防重 (参考:25134-方案2-C需求);
 *      2022.05.18: 修改为dic分组 (参考26042-TODO1);
 *      2022.05.21: 排序方式以价值综评分为准 (参考26073-TODO11);
 *  @result notnull
 */
-(NSDictionary*) fos4Demand{
    //1. 返回分组字典;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 排序方式 (从小到大);
    NSArray *sortPFos = [SMGUtils sortBig2Small:self.matchPFos compareBlock:^double(AIMatchFoModel *obj) {
        return -[AIScore score4MV_v2FromCache:obj];//负(价值评分 * 匹配度) 如: [-8,-3,2,9]
    }];
    
    //2. 根据mv的AT标识分组;
    for (AIMatchFoModel *pFo in sortPFos) {
        AIFoNodeBase *fo = [SMGUtils searchNode:pFo.matchFo];
        
        //3. 取分组;
        NSMutableArray *itemArr = [result objectForKey:fo.cmvNode_p.algsType];
        if (!itemArr) itemArr = [[NSMutableArray alloc] init];
        
        //4. 收集到分组;
        [itemArr addObject:pFo];
        [result setObject:itemArr forKey:fo.cmvNode_p.algsType];
    }
    return result;
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
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        return item.cutIndex >= matchFo.count - 1;
    }];
    
    //2. 排序;
    fullMatchs = [fullMatchs sortedArrayUsingComparator:^NSComparisonResult(AIMatchFoModel *o1, AIMatchFoModel *o2) {
        AIFoNodeBase *mFo1 = [SMGUtils searchNode:o1.matchFo];
        AIFoNodeBase *mFo2 = [SMGUtils searchNode:o2.matchFo];
        return [SMGUtils compareIntA:mFo1.count intB:mFo2.count];
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
        AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
        return item.cutIndex < matchFo.count - 1;
    }];
    
    //2. 返10条;
    return ARR_SUB(partMatchs, 0, 10);
}

-(void) log4HavXianWuJv_AlgPJ:(NSString*)prefix {
    //调试有向无距果场景在试错训练中的竞争变化 (参考33108-调试日志);
    for (AIMatchAlgModel *item in self.matchAlgs_PJ) {
        AIKVPointer *xianV = [NVHeUtil getXian:item.matchAlg];
        AIKVPointer *jvV = [NVHeUtil getJv:item.matchAlg];
        if (xianV && !jvV) {
            NSLog(@"%@ %lld 概念识别 有向无距果 index: %ld/%ld",prefix,theTC.getLoopId,[self.matchAlgs_PJ indexOfObject:item],self.matchAlgs_PJ.count);
            return;
        }
    }
}

-(void) log4HavXianWuJv_PFos:(NSString*)prefix {
    for (AIMatchFoModel *item in self.matchPFos) {
        NSString *matchFoDesc = Pit2FStr(item.matchFo);
        //调试有向无距果场景在试错训练中的竞争变化 (参考33108-调试日志);
        if ([matchFoDesc containsString:@"有向无距"]) {
            NSLog(@"%@ %lld 时序识别 有向无距果 index: %ld/%ld",prefix,theTC.getLoopId,[self.matchPFos indexOfObject:item],self.matchPFos.count);
            return;
        }
    }
}

@end
