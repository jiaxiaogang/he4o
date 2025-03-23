//
//  AIFeatureNextGVRankModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/23.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureNextGVRankModel.h"

@implementation AIFeatureNextGVRankModel

/**
 *  MARK:--------------------更新一条--------------------
 */
-(void) update:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree {
    //1. 数据检查
    if (!self.protoDic) self.protoDic = [[NSMutableDictionary alloc] init];
    
    //2. newItem
    AIFeatureNextGVRankItem *item = [[AIFeatureNextGVRankItem alloc] init];
    item.refPort = refPort;
    item.gMatchValue = gMatchValue;
    item.gMatchDegree = gMatchDegree;
    
    //3. add to items then add to dic;
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.protoDic objectForKey:assKey]];
    [items addObject:item];
    [self.protoDic setObject:items forKey:assKey];
}

/**
 *  MARK:--------------------竞争只保留最好一条--------------------
 */
-(void) invokeRank {
    //1. 数据准备
    self.rankDic = [[NSMutableDictionary alloc] init];
    
    //2. 每个items都竞争下best一条。
    for (NSString *assKey in self.protoDic.allKeys) {
        NSArray *items = ARRTOOK([self.protoDic objectForKey:assKey]);
        items = [SMGUtils sortBig2Small:items compareBlock1:^double(AIFeatureNextGVRankItem *obj) {
            return obj.gMatchDegree;
        } compareBlock2:^double(AIFeatureNextGVRankItem *obj) {
            return obj.gMatchValue;
        }];
        
        //3. 每个items只保留最best一条。
        [self.rankDic setObject:ARR_INDEX(items, 0) forKey:assKey];
    }
}

@end
