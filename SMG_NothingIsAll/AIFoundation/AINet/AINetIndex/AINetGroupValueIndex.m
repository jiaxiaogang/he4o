//
//  AINetGroupValueIndex.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/27.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AINetGroupValueIndex.h"

@implementation AINetGroupValueIndex

//MARK:===============================================================
//MARK:                     < 主方法：存取 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新一条gNode到索引序列--------------------
 */
+(void) updateGVIndex:(AIGroupValueNode*)gNode {
    //1. 生成gv索引指针地址。
    AIKVPointer *gvIndex_p = [self createGVIndex_p:gNode];
    
    //2. 从索引目录下取出索引序列。
    NSMutableArray *oldIndexs = [[NSMutableArray alloc] initWithArray:[SMGUtils searchGVIndexForPointer:gvIndex_p]];
    
    //3. 将新的gNode.p加入其中。
    if (![oldIndexs containsObject:@(gNode.pId)]) {
        [oldIndexs addObject:@(gNode.pId)];
        [SMGUtils insertGVIndex:oldIndexs gvIndex_p:gvIndex_p];
    }
}

/**
 *  MARK:--------------------根据gNode取索引序列--------------------
 */
+(NSArray*) getGVIndex:(AIGroupValueNode*)gNode {
    AIKVPointer *gvIndex_p = [self createGVIndex_p:gNode];
    return ARRTOOK([SMGUtils searchGVIndexForPointer:gvIndex_p]);
}

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------为组节点建索引 并 返回索引指针（参考34081-方案1）--------------------
 */
+(AIKVPointer*) createGVIndex_p:(AIGroupValueNode*)gNode {
    //1. 单码取值。
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
            [sortIndexs2 addObject:@([self convertZeroOneToZeroNine:nextRankNum - curRankNum])];
        }
    }
    
    //21. 收集平均值（参考34081-解决2）。
    float sumNum = [SMGUtils sumOfArr:contentNums convertBlock:^double(NSNumber *obj) {
        return obj.floatValue;
    }];
    float pinJunNum = contentNums.count == 0 ? 0 : sumNum / contentNums.count;
 
    //22. 把精度处理成0-9。
    [sortIndexs2 addObject:@([self convertZeroOneToZeroNine:pinJunNum])];
    
    //23. 把sortIndexs2转成以/分隔的路径字符串，并生成为gvIndex指针地址。
    NSString *sortIndexsStr = ARRTOSTR(sortIndexs2, @"/", @"");
    NSString *at = STRFORMAT(@"%@%@",gNode.p.algsType,sortIndexsStr);
    AIKVPointer *gvIndex_p = [SMGUtils createPointerForGroupValueIndex:at ds:gNode.p.dataSource isOut:gNode.p.isOut];
    return gvIndex_p;
}

//把0-1转成0-9
+(int) convertZeroOneToZeroNine:(CGFloat)zeroOne {
    return zeroOne == 1 ? 9 : (int)(zeroOne * 10);
}

@end
