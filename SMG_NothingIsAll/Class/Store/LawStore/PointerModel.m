//
//  PointerModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "PointerModel.h"

@implementation PointerModel

+(PointerModel*) initWithClass:(Class)c withId:(NSInteger)i {
    PointerModel *model = [[PointerModel alloc] init];
    model.pointerClass = c;
    model.pointerId = i;
    return model;
}

@end
