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
 *  MARK:--------------------根据组节点取 三个索引的数据（参考34082-方案2）--------------------
 *  @param subDots MapModel类型: v1=colorValue v2=x(0-2) v3-y(0-2)
 */
+(NSDictionary*) convertGVIndexData:(NSArray*)subDots ds:(NSString*)ds {
    //1. 单码取值。
    NSArray *contentNums = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v1;
    }];
    NSArray *xs = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v2;
    }];
    NSArray *ys = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v3;
    }];
    
    //2. 求平均值（参考34082-TODO3）。
    float sumNum = [SMGUtils sumOfArr:contentNums convertBlock:^double(NSNumber *obj) {
        return obj.floatValue;
    }];
    float pinJunNum = contentNums.count == 0 ? 0 : sumNum / contentNums.count;
    pinJunNum = roundf(pinJunNum * 25) / 25;
    
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
    float diffPinJunNum = [CortexAlgorithmsUtil deltaOfCustomV1:bigerPinJunNum v2:smallPinJunNum max:1 min:0 loop:[CortexAlgorithmsUtil dsIsLoop:ds]];
    diffPinJunNum = roundf(diffPinJunNum * 25) / 25;
    
    //5. 方向：根据大小区中心点，算出方向（参考34082-TODO1）（按左上角为0,0点算，所以要加0.5表示xy坐标的中心点位置）。
    CGFloat bigerPinJunX = [SMGUtils sumOfArr:bigerIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(xs, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat bigerPinJunY = [SMGUtils sumOfArr:bigerIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(ys, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat smallPinJunX = [SMGUtils sumOfArr:smallIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(xs, index.integerValue)).integerValue + 0.5;
    }];
    CGFloat smallPinJunY = [SMGUtils sumOfArr:smallIndexs convertBlock:^double(NSNumber *index) {
        return NUMTOOK(ARR_INDEX(ys, index.integerValue)).integerValue + 0.5;
    }];
    
    //6. 方向：将距离转成角度-PI -> PI (从右至左,上面为-0 -> -3.14 / 从右至左,下面为0 -> 3.14)，然后归1化，再然后保留1%精度。
    CGFloat rads = atan2f(bigerPinJunY - smallPinJunY,bigerPinJunX - smallPinJunX);
    float protoParam = (rads / M_PI + 1) / 2;
    float direction = roundf(protoParam * 36) / 36;
    
    //7. 创建三个索引的指针地址：均值、差值、方向。
    return @{STRFORMAT(@"%@_direction",ds): @(direction),
             STRFORMAT(@"%@_diff",ds): @(diffPinJunNum),
             STRFORMAT(@"%@_jun",ds): @(pinJunNum)};
}

//把0-1转成0-9
+(int) convertZeroOneToZeroNine:(CGFloat)zeroOne {
    return zeroOne == 1 ? 9 : (int)(zeroOne * 10);
}

@end
