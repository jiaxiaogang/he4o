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

@implementation TVUtil

/**
 *  MARK:--------------------获取两帧工作记忆的更新处--------------------
 */
+(NSArray*) getChanges:(NSArray*)firstRoots secondRoots:(NSArray*)secondRoots{
    //1. 数据准备;
    NSArray *firstSubs = [self collectAllSubTOModelByRoots:firstRoots];
    NSArray *secondSubs = [self collectAllSubTOModelByRoots:secondRoots];
    
    //2. 将更新返回 (second包含 & first不包含);
    return [SMGUtils filterArr:secondSubs checkValid:^BOOL(id item) {
        return ![firstSubs containsObject:item];
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
