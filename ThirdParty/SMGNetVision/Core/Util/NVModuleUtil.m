//
//  NVModuleUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/10.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVModuleUtil.h"
#import "NodeCompareModel.h"

@implementation NVModuleUtil

+(NSArray*) getOrCreateGroupWithData:(id)data groups:(NSMutableArray*)groups{
    //1. 无效则返nil;
    if (!data) {
        return nil;
    }
    
    //2. 找已有,则取出;
    if (ISOK(groups, NSMutableArray.class)) {
        for (NSArray *oldGroup in groups) {
            if ([oldGroup containsObject:data]) {
                return oldGroup;
            }
        }
    }
    
    //3. 没找到,则新建
    NSArray *newGroup = @[data];
    [groups addObject:newGroup];
    return newGroup;
}

+(BOOL) isRelateWithData1:(id)data1 data2:(id)data2 compareModels:(NSArray*)compareModels{
    //1. 数据检查
    compareModels = ARRTOOK(compareModels);
    if (data1 && data2) {
        //2. 检查data1和data2是否有关系
        for (NodeCompareModel *model in compareModels) {
            if ([model isA:data1 andB:data2]) {
                return true;
            }
        }
    }
    return false;
}

+(NSComparisonResult)compareNodeData1:(id)n1 nodeData2:(id)n2 compareModels:(NSArray*)compareModels{
    //1. 数据检查
    if (n1 && n2) {
        compareModels = ARRTOOK(compareModels);
        
        //2. 判断n1与n2的关系,并返回大或小; (越小,越排前面)
        for (NodeCompareModel *model in compareModels) {
            if ([model isA:n1 andB:n2]) {
                return [n1 isEqual:model.smallNodeData] ? NSOrderedAscending : NSOrderedDescending;
            }
        }
    }
    //3. 无关系异常
    return NSOrderedSame;
}

+(NSMutableArray*) getSortGroups:(NSArray*)nodeArr compareModels:(NSArray*)compareModels{
    //1. 数据检查
    compareModels = ARRTOOK(compareModels);
    nodeArr = ARRTOOK(nodeArr);
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    //2. 用相容算法,分组 (一一对比,并合并);
    for (NSInteger i = 0; i < nodeArr.count; i++) {
        for (NSInteger j = i + 1; j < nodeArr.count; j++) {
            id iData = ARR_INDEX(nodeArr, i);
            id jData = ARR_INDEX(nodeArr, j);
            NSArray *iGroup = [NVModuleUtil getOrCreateGroupWithData:iData groups:groups];
            NSArray *jGroup = [NVModuleUtil getOrCreateGroupWithData:jData groups:groups];
            
            ///1. 当iData和jData有关系时;
            if ([NVModuleUtil isRelateWithData1:iData data2:jData compareModels:compareModels]) {
                ///2. 有关系,则移除合并前的group;
                [groups removeObject:iGroup];
                [groups removeObject:jGroup];
                
                ///3. 并将iGroup和jGroup合并,加到groups;
                NSMutableArray *mergeGroup = [[NSMutableArray alloc] init];
                [mergeGroup addObjectsFromArray:iGroup];
                [mergeGroup addObjectsFromArray:jGroup];
                [groups addObject:mergeGroup];
            }
        }
    }
    
    //3. 对groups中,每一组进行独立排序,并取编号结果; (排序:从具象到抽象)
    NSMutableArray *sortGroups = [[NSMutableArray alloc] init];
    for (NSArray *group in groups) {
        NSArray *sortGroup = [group sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [NVModuleUtil compareNodeData1:obj1 nodeData2:obj2 compareModels:compareModels];
        }];
        [sortGroups addObject:sortGroup];
    }
    return sortGroups;
}

+(BOOL) containsRelateWithData:(id)checkData fromGroup:(NSArray*)group compareModels:(NSArray*)compareModels{
    //1. 数据检查
    group = ARRTOOK(group);
    
    //2. 检查group中,是否有元素与checkData有关系;
    if (checkData) {
        for (id groupData in group) {
            if ([NVModuleUtil isRelateWithData1:checkData data2:groupData compareModels:compareModels]) {
                return true;
            }
        }
    }
    return false;
}

@end
