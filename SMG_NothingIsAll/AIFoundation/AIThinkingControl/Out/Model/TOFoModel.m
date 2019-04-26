//
//  TOFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOFoModel.h"

@implementation TOFoModel

-(NSMutableArray *)except_ps{
    if (!_except_ps) {
        _except_ps = [[NSMutableArray alloc] init];
    }
    return _except_ps;
}

//-(NSMutableArray *)memOrder{
//    if (!_memOrder) {
//        _memOrder = [[NSMutableArray alloc] init];
//    }
//    return _memOrder;
//}

@end
