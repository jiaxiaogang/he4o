//
//  AINetDirectionReference.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetDirectionReference.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AINetUtils.h"

@implementation AINetDirectionReference

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem limit:(NSInteger)limit {
    return [self getNodePointersFromDirectionReference:mvAlgsType direction:direction isMem:isMem filter:^NSArray *(NSArray *protoArr) {
        if (ARRISOK(protoArr)) {
            if (!isMem) {
                NSLog(@"检查下,当前protoArr序列,是否'从强到弱'排序;");
            }
            return ARR_SUB(protoArr, 0, limit);
            //NSInteger subLimit = MAX(0, MIN(limit, protoArr.count));
            //return [protoArr subarrayWithRange:NSMakeRange(protoArr.count - subLimit, subLimit)];
        }
        return nil;
    }];
}


-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem filter:(NSArray*(^)(NSArray *protoArr))filter{
    //1. 取mv分区的引用序列文件;
    AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:mvAlgsType direction:direction];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:mvReference_p fileName:kFNRefPorts_All(isMem) time:cRTMemMvRef_All(isMem)]];
    
    //2. 筛选器
    if (filter) {
        return filter(mArr);
    }
    return nil;
}


@end
