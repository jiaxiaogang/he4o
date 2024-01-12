//
//  NodeCompareModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/14.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NodeCompareModel.h"

@implementation NodeCompareModel

+(NodeCompareModel*) newWithBig:(id)big small:(id)small{
    NodeCompareModel *model = [NodeCompareModel new];
    model.bigNodeData = big;
    model.smallNodeData = small;
    return model;
}

-(BOOL)isA:(id)a andB:(id)b{
    if (a && b) {
        BOOL aIsBig = [a isEqual:self.bigNodeData];
        BOOL aIsSmall = [a isEqual:self.smallNodeData];
        BOOL bIsBig = [b isEqual:self.bigNodeData];
        BOOL bIsSmall = [b isEqual:self.smallNodeData];
        if ((aIsBig && bIsSmall) || (aIsSmall && bIsBig)) {
            return true;
        }
    }
    return false;
}

@end
