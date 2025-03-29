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
 *  @version
 *      2025.03.28: 组码索引序列改成根据平均值有序，然后把它的平均值存在索引中，后面可用来计算组码相近度。
 */
+(void) updateGVIndex:(AIGroupValueNode*)gNode {
    //1. 生成gv索引指针地址。
    NSArray *gvIndexData = [self convertGVIndexData:gNode];
    AIKVPointer *gvIndex_p = [SMGUtils createPointerForGVIndex:gNode.p.algsType ds:gNode.p.dataSource isOut:gNode.p.isOut];
    
    //2. 取出三项索引值。
    for (NSInteger itemIndex = 0; itemIndex < gvIndexData.count; itemIndex++) {
        NSNumber *newNum = ARR_INDEX(gvIndexData, itemIndex);
        
        //3. 从索引目录下取出索引序列。
        NSMutableArray *oldIndexs = [[NSMutableArray alloc] initWithArray:[SMGUtils searchGVIndexForPointer:gvIndex_p itemIndex:itemIndex]];
        
        //4. 找找是否此pId已入过索引。
        BOOL aleardayHav = [SMGUtils filterSingleFromArr:oldIndexs checkValid:^BOOL(NSArray *itemGVIndex) {
            NSInteger oldPId = NUMTOOK(itemGVIndex[0]).integerValue;
            return oldPId == gNode.pId;
        }];
        if (aleardayHav) continue;
        
        //5. 将新的gNode.p加入其中（顺序为平均值从小到大排序）。
        id newObj = @[@(gNode.pId),newNum];
        for (NSInteger i = 0; i < oldIndexs.count; i++) {
            NSArray *itemGVIndex = ARR_INDEX(oldIndexs, i);
            CGFloat oldNum = NUMTOOK(itemGVIndex[1]).floatValue;
            if (oldNum > newNum.floatValue) {
                [oldIndexs insertObject:newObj atIndex:i];
                break;
            }
        }
        if (oldIndexs.count == 0) [oldIndexs addObject:newObj];
        [SMGUtils insertGVIndex:oldIndexs gvIndex_p:gvIndex_p itemIndex:itemIndex];
    }
}

/**
 *  MARK:--------------------根据gNode取索引序列--------------------
 */
+(NSArray*) getGVIndex:(AIGroupValueNode*)gNode itemIndex:(NSInteger)itemIndex {
    //1. 索引目录的指针地址。
    AIKVPointer *gvIndex_p = [SMGUtils createPointerForGVIndex:gNode.p.algsType ds:gNode.p.dataSource isOut:gNode.p.isOut];
    
    //2. 从索引目录下取出索引序列。
    NSArray *allGVIndex = ARRTOOK([SMGUtils searchGVIndexForPointer:gvIndex_p itemIndex:itemIndex]);
    
    //3. 转成组码地址数组返回。
    return [SMGUtils convertArr:allGVIndex convertBlock:^id(NSArray *itemGVIndex) {
        NSNumber *pId = itemGVIndex[0];
        AIKVPointer *p = [SMGUtils createPointerForGroupValue:pId.integerValue at:gNode.p.algsType dataSource:gNode.p.dataSource isOut:gNode.p.isOut];
        return [MapModel newWithV1:p v2:itemGVIndex[1]];
    }];
}

/**
 *  MARK:--------------------根据组节点取 三个索引的数据（参考34082-方案2）--------------------
 */
+(NSArray*) convertGVIndexData:(AIGroupValueNode*)gNode {
    //1. 单码取值。
    NSArray *contentNums = [SMGUtils convertArr:gNode.content_ps convertBlock:^id(AIKVPointer *obj) {
        return [AINetIndex getData:obj];
    }];
    
    //2. 求平均值（参考34082-TODO3）。
    float sumNum = [SMGUtils sumOfArr:contentNums convertBlock:^double(NSNumber *obj) {
        return obj.floatValue;
    }];
    float pinJunNum = contentNums.count == 0 ? 0 : sumNum / contentNums.count;
    
    //3. >均值 和 <均值 的下标数组。
    NSMutableArray *smallIndexs = [NSMutableArray new];
    NSMutableArray *bigerIndexs = [NSMutableArray new];
    for (NSInteger i = 0; i < contentNums.count; i++) {
        float curContentValue = NUMTOOK(ARR_INDEX(contentNums, i)).floatValue;
        if (curContentValue < pinJunNum) {
            [smallIndexs addObject:@(i)];
        } else {
            [bigerIndexs addObject:@(i)];
        }
    }
    
    //4. 差值：求出大小区各自的均值（参考34082-TODO2）。
    float bigerSumNum = [SMGUtils sumOfArr:bigerIndexs convertBlock:^double(NSNumber *obj) {
        NSInteger index = obj.integerValue;
        return NUMTOOK(ARR_INDEX(contentNums, index)).floatValue;
    }];
    float bigerPinJunNum =  bigerIndexs.count > 0 ? bigerSumNum / bigerIndexs.count : 0;
    float smallSumNum = [SMGUtils sumOfArr:contentNums convertBlock:^double(NSNumber *obj) {
        NSInteger index = obj.integerValue;
        return NUMTOOK(ARR_INDEX(contentNums, index)).floatValue;
    }];
    float smallPinJunNum =  smallIndexs.count > 0 ? smallSumNum / smallIndexs.count : 0;
    
    //5. 差值：计算出差值（如果是循环的，则用循环的算法）。
    double max = [CortexAlgorithmsUtil maxOfLoopValue:gNode.p.algsType ds:gNode.p.dataSource itemIndex:GVIndexTypeOfDataSource];
    float diffPinJunNum = [CortexAlgorithmsUtil nearDeltaOfValue:bigerPinJunNum assNum:smallPinJunNum max:max];
    
    //5. 方向：根据大小区中心点，算出方向（参考34082-TODO1）（按左上角为0,0点算，所以要加0.5表示xy坐标的中心点位置）。
    CGFloat bigerPinJunX = [SMGUtils sumOfArr:bigerIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(gNode.xs, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat bigerPinJunY = [SMGUtils sumOfArr:bigerIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(gNode.ys, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat smallPinJunX = [SMGUtils sumOfArr:smallIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(gNode.xs, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat smallPinJunY = [SMGUtils sumOfArr:smallIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(gNode.ys, index.integerValue)).integerValue + 0.5;
    }];
    
    //6. 方向：将距离转成角度-PI -> PI (从右至左,上面为-0 -> -3.14 / 从右至左,下面为0 -> 3.14)，然后归1化，再然后保留1%精度。
    CGFloat rads = atan2f(bigerPinJunY - smallPinJunY,bigerPinJunX - smallPinJunX);
    float protoParam = (rads / M_PI + 1) / 2;
    float direction = roundf(protoParam * 100) / 100;
    
    //7. 创建三个索引的指针地址：均值、差值、方向。
    return @[@(direction), @(diffPinJunNum), @(pinJunNum)];
}

//把0-1转成0-9
+(int) convertZeroOneToZeroNine:(CGFloat)zeroOne {
    return zeroOne == 1 ? 9 : (int)(zeroOne * 10);
}

@end
