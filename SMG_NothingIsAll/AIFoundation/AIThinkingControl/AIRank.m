//
//  AIRank.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/12/19.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIRank.h"

@implementation AIRank

/**
 *  MARK:--------------------概念识别综合排名 (参考2722d-方案2-todo2)--------------------
 *  @result <matchAlg.pId, 综合排名值(越小越靠前)>;
 */
+(NSDictionary*) recognitonAlgRank:(NSArray*)matchAlgModels {
    //1. 数据准备;
    matchAlgModels = ARRTOOK(matchAlgModels);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 分别按相似度和强度排序;
    NSArray *rank4MatchValue = [SMGUtils sortBig2Small:matchAlgModels compareBlock:^double(AIMatchAlgModel *obj) {
        return [obj matchValue];
    }];
    NSArray *rank4StrongValue = [SMGUtils sortBig2Small:matchAlgModels compareBlock:^double(AIMatchAlgModel *obj) {
        return [obj strongValue];
    }];
    
    //3. 求出综合排名;
    for (AIMatchAlgModel *item in matchAlgModels) {
        //4. 取两科排名下标;
        NSInteger index4MatchValue = [rank4MatchValue indexOfObject:item];
        NSInteger index4StrongValue = [rank4StrongValue indexOfObject:item];
        
        //5. 各自归1化;
        CGFloat normalized4MatchValue = index4MatchValue / rank4MatchValue.count;
        CGFloat normalized4StrongValue = index4StrongValue / rank4StrongValue.count;
        
        //6. 计算综合排名;
        [result setObject:@(normalized4MatchValue * normalized4StrongValue) forKey:@(item.matchAlg.pointerId)];
    }
    return result;
}

@end
