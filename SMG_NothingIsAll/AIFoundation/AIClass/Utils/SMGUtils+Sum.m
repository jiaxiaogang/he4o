//
//  SMGUtils+Sum.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "SMGUtils+Sum.h"
#import "AINetIndex.h"
#import "AIPort.h"
#import "NVViewUtil.h"

@implementation SMGUtils (Sum)

/**
 *  MARK:--------------------值域求和--------------------
 *  @desc 束波求和简化版,采取线函数来替代找交点 (参考21212 & 21213);
 *  @result Array[SumModel] notnull
 *  @todo
 *      2021.01.01: 在排序后对同值的元素抵消(s3+p5=p2) (先不实现,因为同值此时交点即会直接取到值,在评价时,似乎这样并没有什么问题);
 */
+(NSArray*) sumSPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts{
    //1. 数据检查;
    sPorts = ARRTOOK(sPorts);
    pPorts = ARRTOOK(pPorts);
    NSArray *allPorts = [SMGUtils collectArrA:sPorts arrB:pPorts];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 从小到大排序;
    [allPorts sortedArrayUsingComparator:^NSComparisonResult(AIPort *p1, AIPort *p2) {
        double v1 = [NUMTOOK([AINetIndex getData:p1.target_p]) doubleValue];
        double v2 = [NUMTOOK([AINetIndex getData:p2.target_p]) doubleValue];
        return [SMGUtils compareFloatA:v2 floatB:v1];
    }];
    
    //3. 取上组和当前组;
    NSMutableArray *lastGroup = [[NSMutableArray alloc] init];
    NSMutableArray *curGroup = [[NSMutableArray alloc] init];
    AnalogyType curType = ATNone;
    for (AIPort *item in allPorts) {
        //4. 切换组: (收集中!=None & 非同组!=itemType);
        AnalogyType itemType = [sPorts containsObject:item] ? ATSub : ATPlus;
        
        //5. 首区间处理 (首个item即先把首区间做了);
        if ([allPorts indexOfObject:item] == 0) {
            [result addObject:[SumModel newWithDotValue:CGFLOAT_MIN type:itemType]];
        }
        
        //6. 中间区间处理 (大于第2组(lastGroup>0)时,对前两组对比生成SubModel处理) (切3时处理2和1);
        if (curType != ATNone && curType != itemType) {
            if (ARRISOK(lastGroup)) {
                SumModel *model = [SMGUtils createSumModel:curType lastGroup:lastGroup curGroup:curGroup];
                if (model) [result addObject:model];
            }
            
            //7. 切区间数据: 当前组变成上组 (当前组重置);
            [lastGroup removeAllObjects];
            [lastGroup addObjectsFromArray:curGroup];
            [curGroup removeAllObjects];
            
        }
        //8. 收集item到curGroup;
        [curGroup addObject:item];
        curType = itemType;
    }
    
    //9. 尾区间处理: 全收集完后,最后一组处理 (lastGroup无效时,说明总共<=1组,不必处理尾区间);
    if (ARRISOK(lastGroup)) {
        SumModel *model = [SMGUtils createSumModel:curType lastGroup:lastGroup curGroup:curGroup];
        if (model) [result addObject:model];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------找出最具竞争力的成员--------------------
 *  @desc 最垂直的即是结果 (参考21215);
 */
+(void) findMostVertical:(AnalogyType)curType curGroup:(NSArray*)curGroup lastGroup:(NSArray*)lastGroup complete:(void(^)(AIPort *lastItem,AIPort *curItem))complete{
    //1. 数据检查;
    curGroup = ARRTOOK(curGroup);
    lastGroup = ARRTOOK(lastGroup);
    
    //2. 遍历找最垂直的: curGroup与lastGroup进行对比找出各自最有竞争力的成员 (参考21215);
    CGFloat mostVerticalAngle = M_PI_4;//默认值为完全水平;
    AIPort *mostFightLastItem = nil;
    AIPort *mostFightCurItem = nil;
    for (AIPort *curItem in curGroup) {
        for (AIPort *lastItem in lastGroup) {
            double curValue = [NUMTOOK([AINetIndex getData:curItem.target_p]) doubleValue];
            double lastValue = [NUMTOOK([AINetIndex getData:lastItem.target_p]) doubleValue];
            CGPoint curPoint = CGPointMake(curValue, curItem.strong.value * (curType == ATSub ? -1 : 1));
            CGPoint lastPoint = CGPointMake(lastValue, lastItem.strong.value * (curType == ATSub ? 1 : -1));
            
            //3. 取两点角度与垂直角的差值最小的则保留;
            CGFloat angle = [NVViewUtil anglePIPoint:curPoint second:lastPoint];
            if (fabs(fabs(angle) - M_PI_2) < fabs(fabs(mostVerticalAngle) - M_PI_2)) {
                mostVerticalAngle = angle;
                mostFightCurItem = curItem;
                mostFightLastItem = lastItem;
            }
        }
    }
    //4. 返回结果;
    if (complete) complete(mostFightLastItem,mostFightCurItem);
}

/**
 *  MARK:--------------------根据最有竞争力成员算出交点--------------------
 */
+(CGFloat) findDotValue:(AIPort*)lastItem curItem:(AIPort*)curItem{
    //1. 数据检查;
    if (!lastItem || !curItem) return CGFLOAT_MIN;
    
    //2. 计算交点: 取两点值;
    double curValue = [NUMTOOK([AINetIndex getData:curItem.target_p]) doubleValue];
    double lastValue = [NUMTOOK([AINetIndex getData:lastItem.target_p]) doubleValue];
    
    //3. 计算交点: 算出比例 (交点与强度是正比的);
    float lastStrong = (float)lastItem.strong.value;
    float totalStrong = (float)lastItem.strong.value + (float)curItem.strong.value;
    float rate = lastStrong / totalStrong;
    
    //4. 根据比例,算出交点并返回;
    float dotValue = lastValue + rate * (curValue - lastValue);
    return dotValue;
}

/**
 *  MARK:--------------------生成SubModel--------------------
 *  @desc
 *      1. 切区间时,对上组和上上组进行对比,并得出SumModel;
 *      2. 上上组为空时,自然会返回nil;
 */
+(SumModel*) createSumModel:(AnalogyType)curType lastGroup:(NSArray*)lastGroup curGroup:(NSArray*)curGroup{
    //1. 数据检查;
    if (curType != ATSub && curType != ATPlus) return nil;
    lastGroup = ARRTOOK(lastGroup);
    curGroup = ARRTOOK(curGroup);
    
    //2. 找出两组各自最有竞争力的成员;
    __block AIPort *mostFightCurItem = nil;
    __block AIPort *mostFightLastItem = nil;
    [SMGUtils findMostVertical:curType curGroup:curGroup lastGroup:lastGroup complete:^(AIPort *lastItem, AIPort *curItem) {
        mostFightLastItem = lastItem;
        mostFightCurItem = curItem;
    }];
    
    //3. 有效时,根据最有竞争力成员算出交点,生成模型,并收集;
    if (mostFightLastItem && mostFightCurItem) {
        float dotValue = [self findDotValue:mostFightLastItem curItem:mostFightCurItem];
        return [SumModel newWithDotValue:dotValue type:curType];
    }
    return nil;
}


@end

@implementation SumModel

+(SumModel*)newWithDotValue:(double)dotValue type:(AnalogyType)type{
    SumModel *model = [[SumModel alloc] init];
    model.dotValue = dotValue;
    model.type = type;
    return model;
}

@end
