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

/**
 *  MARK:--------------------对比n1和n2的大小--------------------
 *  说明:
 *      1. 在compareModels中,数据是一对一的元素,如:[a>b,b>c,c>d,d>e];
 *      2. 我们要的结果可能是对比a与e;
 *      3. 我们先找出含a的元素,得出b;
 *      4. 再找出含b的元素得出c,以此类推,直到找出e;
 *      总结:先找出包含a的元素,并小的向小找,大的向大找,直到找出结果;
 *
 *  异常:
 *      1. 死亡环:(即a>b & b>a的情况),导致的互相引用;
 *      2. 解决:万一有死亡环,仅会导致排版错误;
 *
 *  BUG记录:
 *      1. 因n1,n2并非直接大小,而是间隔了很多个model,导致的返回same排版错误;
 *      2. 复现提示,先直投3个,然后记下最大的conAlgNode,单独追加进来,然后追加其absPorts,直至全纵向加载进来;
 *
 */
+(NSComparisonResult)compareNodeData1:(id)n1 nodeData2:(id)n2 indexDic:(NSDictionary*)indexDic{
    indexDic = DICTOOK(indexDic);
    if (n1 && n2) {
        NSData *key1 = [self keyOfData:n1];
        NSData *key2 = [self keyOfData:n2];
        int index1 = [NUMTOOK([indexDic objectForKey:key1]) intValue];
        int index2 = [NUMTOOK([indexDic objectForKey:key2]) intValue];
        return (index1 == index2) ? NSOrderedSame : ((index1 < index2) ? NSOrderedAscending : NSOrderedDescending);
    }
    return NSOrderedSame;
}

+(NSMutableArray*) getSortGroups:(NSArray*)nodeArr compareModels:(NSArray*)compareModels indexDic:(NSDictionary*)indexDic{
    //1. 数据检查
    indexDic = DICTOOK(indexDic);
    compareModels = ARRTOOK(compareModels);
    nodeArr = ARRTOOK(nodeArr);
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    //2. 用相容算法,分组 (一一对比,并合并);
    for (NSInteger i = 0; i < nodeArr.count; i++) {
        id iData = ARR_INDEX(nodeArr, i);
        NSArray *iGroup = [NVModuleUtil getOrCreateGroupWithData:iData groups:groups];
        for (NSInteger j = i + 1; j < nodeArr.count; j++) {
            id jData = ARR_INDEX(nodeArr, j);
            NSArray *jGroup = [NVModuleUtil getOrCreateGroupWithData:jData groups:groups];
            
            ///1. 当iData和jData有关系时;
            if (![iGroup isEqual:jGroup] && [NVModuleUtil isRelateWithData1:iData data2:jData compareModels:compareModels]) {
                
                ///2. 有关系,则移除合并前的group;
                [groups removeObject:iGroup];
                [groups removeObject:jGroup];
                
                ///3. 并将iGroup和jGroup合并,加到groups;
                NSMutableArray *mergeGroup = [[NSMutableArray alloc] init];
                [mergeGroup addObjectsFromArray:iGroup];
                [mergeGroup addObjectsFromArray:jGroup];
                [groups addObject:mergeGroup];
                
                ///4. 需要重新获取新的iGroup;
                iGroup = [NVModuleUtil getOrCreateGroupWithData:iData groups:groups];
            }
        }
    }
    
    //3. 对groups中,每一组进行独立排序,并取编号结果; (排序:从具象到抽象)
    NSMutableArray *sortGroups = [[NSMutableArray alloc] init];
    for (NSArray *group in groups) {
        NSArray *sortGroup = [group sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [NVModuleUtil compareNodeData1:obj1 nodeData2:obj2 indexDic:indexDic];
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

/**
 *  MARK:--------------------compareModels转为indexDic--------------------
 *  @result nutnull
 */
+(NSDictionary*)convertIndexDicWithCompareModels:(NSArray*)compareModels{
    //1. 数据准备
    compareModels = ARRTOOK(compareModels);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 找出最具象
    for (NodeCompareModel *model in compareModels) {
        //3. 假设当前为最小
        NSArray *smallers = @[model.smallNodeData];
        do {
            NSMutableArray *newSmallers = [[NSMutableArray alloc] init];
            for (id smaller in smallers) {
                //4. 尝试找比假设的最小更小;
                NSArray *models = [self findModelsWithBigData:smaller compareModels:compareModels];
                if (!ARRISOK(models)) {
                    //5. 找不到更小,smaller已经是最小了;
                    [result setObject:@(0) forKey:[self keyOfData:smaller]];
                }else{
                    //6. 有更小,则收集并再假设为最小,继续递归查更小;
                    for (NodeCompareModel *model in models) {
                        [newSmallers addObject:model.smallNodeData];
                    }
                }
            }
            
            //7. 使用新的smallers假设,并递归找更小;
            smallers = newSmallers;
        } while (ARRISOK(smallers));
    }
    
    //8. 列其它index;
    for (NSData *key in result.allKeys) {
        id smaller = [self dataOfKey:key];
        //3. 假设当前为最小
        NSArray *smallers = @[smaller];
        do {
            NSMutableArray *newSmallers = [[NSMutableArray alloc] init];
            for (id smaller in smallers) {
                //4. 尝试找比假设的最小更大;
                NSArray *models = [self findModelsWithSmallData:smaller compareModels:compareModels];
                if (ARRISOK(models)) {
                    //6. 有更大,则index+1;
                    for (NodeCompareModel *model in models) {
                        int smallIndex = [NUMTOOK([result objectForKey:[self keyOfData:smaller]]) intValue];
                        int bigIndex = smallIndex + 1;
                        
                        //7. 存到result中;
                        int oldIndex = [NUMTOOK([result objectForKey:[self keyOfData:model.bigNodeData]]) intValue];
                        int newIndex = MAX(oldIndex, bigIndex);
                        [result setObject:@(newIndex) forKey:[self keyOfData:model.bigNodeData]];
                        
                        //8. 收集新的smallers并递归找更大;
                        [newSmallers addObject:model.bigNodeData];
                    }
                }
            }
            
            //7. 使用新的smallers假设,并递归找更小;
            smallers = newSmallers;
        } while (ARRISOK(smallers));
    }
    return result;
}

/**
 *  MARK:--------------------获取data的key形态--------------------
 */
+(NSData*) keyOfData:(id)data{
    NSData *key = [NSKeyedArchiver archivedDataWithRootObject:data];
    return key;
}
+(id) dataOfKey:(NSData*)key{
    id data = [NSKeyedUnarchiver unarchiveObjectWithData:key];
    return data;
}

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------找出 "抽象/具象" 方向,有关系的models--------------------
 */
+(NSArray*) findModelsWithBigData:(id)bigData compareModels:(NSArray*)compareModels{
    return [self findModelsWithData:bigData dataIsBig:true compareModels:compareModels];
}
+(NSArray*) findModelsWithSmallData:(id)smallData compareModels:(NSArray*)compareModels{
    return [self findModelsWithData:smallData dataIsBig:false compareModels:compareModels];
}
+(NSArray*) findModelsWithData:(id)data dataIsBig:(BOOL)dataIsBig compareModels:(NSArray*)compareModels{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (data && ARRISOK(compareModels)) {
        for (NodeCompareModel *model in compareModels) {
            if ([data isEqual:(dataIsBig ? model.bigNodeData : model.smallNodeData)]) {
                [result addObject:model];
            }
        }
    }
    return result;
}

@end
