//
//  MapStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MapStore.h"

@implementation MapStore


+(MapModel*) insertToDB_MapModel:(MapModel*)model{
    if (model) {
        if([MapModel insertToDB:model]) {
            return model;
        }
    }
    return nil;
}

+(MapModel*) searchSingle_MapModel:(Class)class withClassId:(NSInteger)classId {
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId", nil];
    MapModel *aModel = [MapModel searchSingleWithWhere:aWhere orderBy:nil];
    if (aModel) {
        return aModel;
    }
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId", nil];
    MapModel *bModel = [MapModel searchSingleWithWhere:bWhere orderBy:nil];
    if (bModel) {
        return bModel;
    }
    //未找到
    return nil;
}



@end
