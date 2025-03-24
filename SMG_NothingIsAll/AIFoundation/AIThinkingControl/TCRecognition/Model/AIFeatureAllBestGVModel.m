//
//  AIFeatureAllBestGVModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/24.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureAllBestGVModel.h"

@implementation AIFeatureAllBestGVModel

-(NSMutableDictionary *)bestDic {
    if (!_bestDic) _bestDic = [[NSMutableDictionary alloc] init];
    return _bestDic;
}

/**
 *  MARK:--------------------更新时，直接查下有没重复，有重复的就只保留更优的一条--------------------
 *  @desc 写该方法起因：一般是在特征识别时：多个protoIndex都ref到同一个target的同一帧（如果不去重，会导致特征映射不是一对一）。
 */
-(void) update:(AIFeatureNextGVRankItem*)newItem forKey:(NSString*)assKey {
    //1. 找出已收集到的items。
    NSMutableArray *oldItems = [[NSMutableArray alloc] initWithArray:[self.bestDic objectForKey:assKey]];
    
    //2. 找出重复的oldItem。
    AIFeatureNextGVRankItem *oldItem = [SMGUtils filterSingleFromArr:oldItems checkValid:^BOOL(AIFeatureNextGVRankItem *oldItem) {
        return [oldItem.refPort isEqual:newItem.refPort];
    }];
    
    //3. 重复的没新的好，则去掉重复的留下新的。
    if (oldItem) {
        if (oldItem.gMatchValue * oldItem.gMatchDegree < newItem.gMatchValue * newItem.gMatchDegree) {
            [oldItems removeObject:oldItem];
            [oldItems addObject:newItem];
        }
    } else {
        //4. 没重复的，则直接留下新的。
        [oldItems addObject:newItem];
    }
    [self.bestDic setObject:oldItems forKey:assKey];
}

-(NSArray*) getAssGVModelsForKey:(NSString*)assKey {
    return ARRTOOK([self.bestDic objectForKey:assKey]);
}

@end
