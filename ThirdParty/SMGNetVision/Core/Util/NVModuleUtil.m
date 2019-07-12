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
+(NSComparisonResult)compareNodeData1:(id)n1 nodeData2:(id)n2 compareModels:(NSArray*)compareModels{
    //1. 数据检查
    if (n1 && n2) {
        compareModels = ARRTOOK(compareModels);
        
        //2. 生成n1映射n2,n2映射n1的字典;
        NSArray *keys = @[n1,n2];
        NSArray *values = @[n2,n1];
        
        //3. 分别假设key(n1/n2)为小时,向大的找value(n2/n1);
        for (NSInteger i = 0; i < keys.count; i++) {
            
            //4. key为small,从big方向找value;
            id key = ARR_INDEX(keys, i);
            id value = ARR_INDEX(values, i);
            id smaller = key;
            do {
                //5. 找比small大;
                NodeCompareModel *model = [self findModelWithSmallData:smaller compareModels:compareModels];
                
                //6. 匹配biger = value则成功找到,返回结果 (越小,越排前面);
                if (model && [value isEqual:model.bigNodeData]) {
                    return [n1 isEqual:key] ? NSOrderedAscending : NSOrderedDescending;
                }
                
                //7. 未匹配,则保留新的smaller,循环找比大更大;
                smaller = model ? model.bigNodeData : nil;
            } while (smaller);
        }
    }
    //8. 无关系异常
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
            if (![iGroup isEqual:jGroup] && [NVModuleUtil isRelateWithData1:iData data2:jData compareModels:compareModels]) {
                
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
        
        
        //TODOTOMORROW: 排序算法不对;
        //复现方式:直接乱投一个,然后点击显示出最具象;(即可发现,排序不对,导致的排版错误)
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

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================
+(NodeCompareModel*) findModelWithSmallData:(id)smallData compareModels:(NSArray*)compareModels{
    return [self findModelWithData:smallData dataIsBig:false compareModels:compareModels];
}
+(NodeCompareModel*) findModelWithData:(id)data dataIsBig:(BOOL)dataIsBig compareModels:(NSArray*)compareModels{
    if (data && ARRISOK(compareModels)) {
        for (NodeCompareModel *model in compareModels) {
            if ([data isEqual:(dataIsBig ? model.bigNodeData : model.smallNodeData)]) {
                return model;
            }
        }
    }
    return nil;
}


@end
