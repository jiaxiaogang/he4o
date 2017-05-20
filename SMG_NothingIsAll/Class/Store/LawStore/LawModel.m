//
//  LawModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "LawModel.h"

@implementation LawModel

+(LawModel*) initWithAC:(Class)aClass aI:(NSInteger)aId bC:(Class)bClass bI:(NSInteger)bId{
    LawModel *model = [[LawModel alloc] init];
    model.aClass = aClass;
    model.aId = aId;
    model.bClass = bClass;
    model.bId = bId;
    return model;
}

@end
