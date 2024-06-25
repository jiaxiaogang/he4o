//
//  TCTransferXvModel.m
//  SMG_NothingIsAll
//
//  Created by mac on 2024/3/3.
//  Copyright © 2024年 XiaoGang. All rights reserved.
//

#import "TCTransferXvModel.h"

@implementation TCTransferXvModel

//TODOTOMORROW20240625: 查下indexDic映射越界的问题 (参考32014);
-(void)setSceneToCansetToIndexDic:(NSDictionary *)value {
    _sceneToCansetToIndexDic = value;
    NSNumber *maxValue = ARR_INDEX([SMGUtils sortBig2Small:value.allValues compareBlock:^double(NSNumber *obj) {
        return obj.doubleValue;
    }], 0);
    if (maxValue.integerValue > self.cansetToOrders.count) {
        NSLog(@"value越界");
    }
}

@end
