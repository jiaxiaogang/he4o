//
//  AINetGroupValueIndex.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/27.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AINetGroupValueIndex.h"

@implementation AINetGroupValueIndex

/**
 *  MARK:--------------------为组节点建索引（参考34081-方案1）--------------------
 */
+(void) createGVIndex:(AIGroupValueNode*)gNode {
    //1. 单码取值。
    if (gNode.count == 0) return;
    NSArray *contentNums = [SMGUtils convertArr:gNode.content_ps convertBlock:^id(AIKVPointer *obj) {
        return [AINetIndex getData:obj];
    }];
    
    //2. 下标数组。
    NSMutableArray *protoIndexs = [NSMutableArray new];
    for (NSInteger i = 0; i < contentNums.count; i++) [protoIndexs addObject:@(i)];
    
    //3. 下标按单码从小到大排序（参考34081-说明1）。
    NSArray *sortIndexs = [SMGUtils sortSmall2Big:protoIndexs compareBlock:^double(NSNumber *obj) {
        NSInteger index = obj.integerValue;
        return NUMTOOK(ARR_INDEX(contentNums, index)).floatValue;
    }];

    //11. 收集排序下标 和 差值（参考34081-解决1）。
    NSMutableArray *sortIndexs2 = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < sortIndexs.count; i++) {
        
        //12. 先收集排序下标。
        NSInteger curRankIndex = NUMTOOK(ARR_INDEX(sortIndexs, i)).integerValue;
        [sortIndexs2 addObject:@(curRankIndex)];
        
        //13. 再收集差值。
        if (i < sortIndexs.count - 1) {
            NSInteger nextRankIndex = NUMTOOK(ARR_INDEX(sortIndexs, i+1)).integerValue;
            float curRankNum = NUMTOOK(ARR_INDEX(contentNums, curRankIndex)).floatValue;
            float nextRankNum = NUMTOOK(ARR_INDEX(contentNums, nextRankIndex)).floatValue;
            
            //14. 把精度处理成0-9。
            [sortIndexs2 addObject:@(nextRankNum - curRankNum)];
        }
    }
    
    //21. 收集平均值（参考34081-解决2）。
    float sumNum = [SMGUtils sumOfArr:contentNums convertBlock:^double(NSNumber *obj) {
        return obj.floatValue;
    }];
    float pinjunNum = sumNum / contentNums.count;
 
    //22. 把精度处理成0-9。
    [sortIndexs2 addObject:@(pinjunNum)];
    
    
    //TODOTOMORROW20250327: 参考step1在AINetIndex的单码建索引，这里对组码也要建下索引。
    
    //31. 从索引目录下取出索引序列。
    
    //32. 将新的gNode.p加入其中。
    
}

/**
 *  MARK:--------------------根据gNode取索引序列--------------------
 */
-(NSArray*) getGVIndex:(AIGroupValueNode*)gNode {
    //1. 根据
    return nil;
}

@end
