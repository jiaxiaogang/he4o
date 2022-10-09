//
//  AINetDirectionReference.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetDirectionReference.h"
#import "PINCache.h"

@implementation AINetDirectionReference

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(NSInteger)limit {
    return [self getNodePointersFromDirectionReference:mvAlgsType direction:direction filter:^NSArray *(NSArray *protoArr) {
        return ARR_SUB(protoArr, 0, limit);
    }];
}

-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction filter:(NSArray*(^)(NSArray *protoArr))filter{
    //1. 取mv分区的引用序列文件;
    AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:mvAlgsType direction:direction];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:mvReference_p fileName:kFNRefPorts time:cRTMvRef]];
    
    //2. 筛选器 (无筛选器时,返回所有);
    if (filter) {
        return filter(mArr);
    }
    return mArr;
}


@end
