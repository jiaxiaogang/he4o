//
//  AIStoreBase.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStoreBase.h"

@implementation AIStoreBase

+(id) searchSingleRowId:(NSInteger)rowId{
    return [[self getModelClass] searchSingleWithWhere:[DBUtils sqlWhere_RowId:rowId] orderBy:nil];
}

+(id) searchSingleWhere:(id)where{
    return [[self getModelClass] searchSingleWithWhere:where orderBy:nil];
}

+(NSMutableArray*) searchWhere:(id)where count:(NSInteger)count{
    return [[self getModelClass] searchWithWhere:where orderBy:nil offset:0 count:count];
}

+(void) insert:(AIObject*)data awareness:(BOOL)awareness{
    if (data) {
        //1,存data
        [data.class insertToDB:data];
        
        //2,存意识流
        if (awareness) {
            AIAwarenessModel *awareModel = [[AIAwarenessModel alloc] init];
            awareModel.awarenessP = data.pointer;
            [AIAwarenessStore insert:awareModel awareness:false];
        }
    }
}

+(Class) getModelClass{
    NSString *storeStr = NSStringFromClass([self class]);
    if (STRISOK(storeStr) && storeStr.length > 5 && [@"Store" isEqualToString:[storeStr substringFromIndex:storeStr.length - 5]]) {
        NSString *modelStr = STRFORMAT(@"%@Model",[storeStr substringToIndex:storeStr.length - 5]);
        Class modelClass = NSClassFromString(modelStr);
        return modelClass;
    }
    return nil;
}

@end
