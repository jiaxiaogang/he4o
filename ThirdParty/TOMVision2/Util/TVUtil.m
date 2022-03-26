//
//  TVUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/26.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TVUtil.h"
#import "TOModelVisionUtil.h"
#import "UnorderItemModel.h"
#import "TOMVisionItemModel.h"

@implementation TVUtil

/**
 *  MARK:--------------------获取所有帧工作记忆的两两更新比对--------------------
 *  @desc 注: 包括首帧时,也要和-1帧nil比对;
 *  @result DIC<K:后帧下标, V:变化数组> notnull;
 */
+(NSMutableDictionary*) getChange_List:(NSArray*)models {
    //1. 数据检查;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (!ARRISOK(models)) return result;
    
    //2. 两两比对;
    for (NSInteger b = 0; b < models.count; b++) {
        TOMVisionItemModel *itemB = ARR_INDEX(models, b);
        TOMVisionItemModel *itemA = ARR_INDEX(models, b - 1);
        NSArray *itemChanges = [self getChange_Item:itemA itemB:itemB];
        [result setObject:itemChanges forKey:@(b)];
    }
    return result;
}

/**
 *  MARK:--------------------获取两帧工作记忆的更新处--------------------
 *  @result itemB中新增的变化数 notnull;
 */
+(NSArray*) getChange_Item:(TOMVisionItemModel*)itemA itemB:(TOMVisionItemModel*)itemB{
    //1. 数据准备;
    NSArray *subsA = itemA ? [self collectAllSubTOModelByRoots:itemA.roots] : [NSArray new];
    NSArray *subsB = itemB ? [self collectAllSubTOModelByRoots:itemB.roots] : [NSArray new];
    
    //2. 将更新返回 (second包含 & first不包含);
    return [SMGUtils filterArr:subsB checkValid:^BOOL(id item) {
        return ![subsA containsObject:item];
    }];
}

//收集roots下面所有的枝叶 notnull;
+(NSMutableArray*) collectAllSubTOModelByRoots:(NSArray*)roots {
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    roots = ARRTOOK(roots);
    
    //2. 收集
    for (DemandModel *root in roots) {
        NSMutableArray *unorderModels = [TOModelVisionUtil convertCur2Sub2UnorderModels:root];
        [result addObjectsFromArray:[SMGUtils convertArr:unorderModels convertBlock:^id(UnorderItemModel *obj) {
            return obj.data;
        }]];
    }
    return result;
}

/**
 *  MARK:--------------------changeDic的变化总数--------------------
 *  @result 取值为1-length
 */
+(NSInteger) count4ChangeDic:(NSDictionary*)changeDic{
    //1. 数据准备;
    changeDic = DICTOOK(changeDic);
    NSInteger result = 0;
    
    //2. 累计changeCount;
    for (NSArray *value in changeDic.allValues) {
        result += MAX(1, value.count);
    }
    return result;
}

/**
 *  MARK:--------------------changeIndex转index--------------------
 *  @result 返回NSRange的第1位表示mainIndex,第2位表示subIndex
 *      1. 未找到结果时为-1;
 *      2. 其中mainIndex和subIndex的范围都是"0-(count-1)";
 */
+(NSInteger) mainIndexOfChangeIndex:(NSInteger)changeIndex changeDic:(NSDictionary*)changeDic{
    return [self indexOfChangeIndex:changeIndex changeDic:changeDic].location;
}
+(NSInteger) subIndexOfChangeIndex:(NSInteger)changeIndex changeDic:(NSDictionary*)changeDic{
    return [self indexOfChangeIndex:changeIndex changeDic:changeDic].length;
}
+(NSRange) indexOfChangeIndex:(NSInteger)changeIndex changeDic:(NSDictionary*)changeDic {
    //1. 数据准备;
    changeDic = DICTOOK(changeDic);
    NSInteger sumChangeCount = 0;
    
    //2. 累计changeCount;
    for (NSInteger i = 0; i < changeDic.count; i++) {
        NSNumber *key = @(i+1); //key为1-changeCount
        NSArray *value = [changeDic objectForKey:key];
        
        //3. 当sum + curCount < changeIndex时,说明还没达到,累计并继续for向下找;
        if (sumChangeCount + MAX(1, value.count) < changeIndex) {
            sumChangeCount += MAX(1, value.count);
        }else {
            
            //4. 否则,说明要找的目标就在当前key中;
            NSInteger mainIndex = key.integerValue - 1;//mainIndex
            NSInteger subIndex = value.count ? changeIndex - sumChangeCount - 1 : -1;
            return NSMakeRange(mainIndex, subIndex);
        }
    }
    return NSMakeRange(-1, -1);
}

@end
