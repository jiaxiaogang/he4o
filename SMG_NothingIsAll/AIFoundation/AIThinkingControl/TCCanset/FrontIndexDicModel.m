//
//  FrontIndexDicModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/30.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "FrontIndexDicModel.h"

@implementation FrontIndexDicModel

+(FrontIndexDicModel*) newWithProtoIndex:(NSInteger)protoIndex cansetIndex:(NSInteger)cansetIndex transferAlg:(AIKVPointer*)transferAlg_p {
    FrontIndexDicModel *result = [[FrontIndexDicModel alloc] init];
    result.protoIndex = protoIndex;
    result.cansetIndex = cansetIndex;
    result.transferAlg_p = transferAlg_p;
    return result;
}

@end
