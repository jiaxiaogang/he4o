//
//  MapModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MapModel.h"

@implementation MapModel

+(MapModel*) initWithAC:(Class)aClass aI:(NSInteger)aId bC:(Class)bClass bI:(NSInteger)bId{
    MapModel *model = [[MapModel alloc] init];
    model.aClass = aClass;
    model.aId = aId;
    model.bClass = bClass;
    model.bId = bId;
    return model;
}

@end
