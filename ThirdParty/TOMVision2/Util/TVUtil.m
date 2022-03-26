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

@end
