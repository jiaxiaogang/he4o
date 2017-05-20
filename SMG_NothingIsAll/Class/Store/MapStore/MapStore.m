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
        model.count ++;//保存时,计数器+1;
        if([MapModel insertToDB:model]) {
            return model;
        }
    }
    return nil;
}

+(MapModel*) searchSingle_MapModel:(Class)class withClassId:(NSInteger)classId {
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId", nil];
    MapModel *aModel = [self searchSingle_MapModel:aWhere];
    if (aModel) return aModel;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId", nil];
    MapModel *bModel = [self searchSingle_MapModel:bWhere];
    if (bModel) return bModel;
    //未找到
    return nil;
}

+(NSInteger) searchSingle_OtherIdWithClass:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass{
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId",otherClass,@"bClass", nil];
    MapModel *aModel = [self searchSingle_MapModel:aWhere];
    if (aModel) return aModel.bId;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId",otherClass,@"aClass", nil];
    MapModel *bModel = [self searchSingle_MapModel:bWhere];
    if (bModel) return bModel.aId;
    //未找到
    return 0;
}

+(MapModel*) searchSingle_MapModel:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass{
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId",otherClass,@"bClass", nil];
    MapModel *aModel = [self searchSingle_MapModel:aWhere];
    if (aModel) return aModel;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId",otherClass,@"aClass", nil];
    MapModel *bModel = [self searchSingle_MapModel:bWhere];
    if (bModel) return bModel;
    //未找到
    return nil;
}


+(MapModel*) searchSingle_MapModel:(NSDictionary*)where{
    if (DICISOK(where)) {
        MapModel *aModel = [MapModel searchSingleWithWhere:where orderBy:nil];
        if (aModel) {
            aModel.count ++;
            [MapModel updateToDB:aModel where:[DBUtils sqlWhere_RowId:aModel.rowid]];//计数器+1并保存;
            return aModel;
        }
    }
    return nil;
}


@end
