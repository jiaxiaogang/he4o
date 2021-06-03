//
//  TOModelVisionUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/3.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOModelVisionUtil.h"
#import "UnorderItemModel.h"
#import "TOModelBase.h"
#import "TOUtils.h"

@implementation TOModelVisionUtil

+(NSMutableArray*) convertCur2Sub2UnorderModels:(TOModelBase*)curModel{
    return [self convertCur2Sub2UnorderModels:curModel curTabNum:0];
}
+(NSMutableArray*) convertCur2Sub2UnorderModels:(TOModelBase*)curModel curTabNum:(int)curTabNum{
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!curModel) return result;
    
    //2. 收集当前
    UnorderItemModel *model = [[UnorderItemModel alloc] init];
    model.data = curModel;
    model.tabNum = curTabNum;
    [result addObject:model];
    
    //3. 取所有分支;
    NSMutableArray *subModels = [TOUtils getSubOutModels:curModel];
    for (TOModelBase *subModel in subModels) {
        
        //4. 分支再递归其分支 (并缩进+1);
        NSMutableArray *subAllDeep = [self convertCur2Sub2UnorderModels:subModel curTabNum:curTabNum + 1];
        [result addObjectsFromArray:subAllDeep];
    }
    return result;
}

@end
