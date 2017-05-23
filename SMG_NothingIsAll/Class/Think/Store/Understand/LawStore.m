//
//  LawStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "LawStore.h"

@implementation LawStore


+(LawModel*) insertToDB_LawModel:(LawModel*)model{
    if (model) {
        model.count ++;//保存时,计数器+1;
        if([LawModel insertToDB:model]) {
            return model;
        }
    }
    return nil;
}

+(LawModel*) searchSingle_LawModel:(Class)class withClassId:(NSInteger)classId {
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId", nil];
    LawModel *aModel = [self searchSingle_LawModel:aWhere];
    if (aModel) return aModel;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId", nil];
    LawModel *bModel = [self searchSingle_LawModel:bWhere];
    if (bModel) return bModel;
    //未找到
    return nil;
}

+(NSInteger) searchSingle_OtherIdWithClass:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass{
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId",otherClass,@"bClass", nil];
    LawModel *aModel = [self searchSingle_LawModel:aWhere];
    NSLog(@"");
    //if (aModel) return aModel.bId;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId",otherClass,@"aClass", nil];
    LawModel *bModel = [self searchSingle_LawModel:bWhere];
    //if (bModel) return bModel.aId;
    //未找到
    return 0;
}

+(LawModel*) searchSingle_LawModel:(Class)class withClassId:(NSInteger)classId otherClass:(Class)otherClass{
    //找A
    NSDictionary *aWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"aClass",@(classId),@"aId",otherClass,@"bClass", nil];
    LawModel *aModel = [self searchSingle_LawModel:aWhere];
    if (aModel) return aModel;
    //找B
    NSDictionary *bWhere = [[NSDictionary alloc] initWithObjectsAndKeys:class,@"bClass",@(classId),@"bId",otherClass,@"aClass", nil];
    LawModel *bModel = [self searchSingle_LawModel:bWhere];
    if (bModel) return bModel;
    //未找到
    return nil;
}


+(LawModel*) searchSingle_LawModel:(NSDictionary*)where{
    if (DICISOK(where)) {
        LawModel *aModel = [LawModel searchSingleWithWhere:where orderBy:nil];
        if (aModel) {
            aModel.count ++;
            [LawModel updateToDB:aModel where:[DBUtils sqlWhere_RowId:aModel.rowid]];//计数器+1并保存;
            return aModel;
        }
    }
    return nil;
}


@end
