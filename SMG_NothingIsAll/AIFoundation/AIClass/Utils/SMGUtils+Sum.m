//
//  SMGUtils+Sum.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "SMGUtils+Sum.h"
#import "AINetIndex.h"
#import "AIPort.h"

@implementation SMGUtils (Sum)

/**
 *  MARK:--------------------值域求和--------------------
 *  @desc 波求和,不过采取线函数来替代找交点 (参考21212 & 21213);
 */
+(void) sumPortsA:(NSArray*)as portsB:(NSArray*)bs{
    //1. 数据检查;
    as = ARRTOOK(as);
    bs = ARRTOOK(bs);
    NSArray *alls = [SMGUtils collectArrA:as arrB:bs];
    
    //2. 从小到大排序;
    [alls sortedArrayUsingComparator:^NSComparisonResult(AIPort *p1, AIPort *p2) {
        double v1 = [NUMTOOK([AINetIndex getData:p1.target_p]) doubleValue];
        double v2 = [NUMTOOK([AINetIndex getData:p2.target_p]) doubleValue];
        return [SMGUtils compareFloatA:v2 floatB:v1];
    }];
    
    
    
    
}


+(NSArray*) getFuzzySortWithMaskValue:(AIKVPointer*)maskValue_p fromProto_ps:(NSArray*)proto_ps{
    //a. 对result2筛选出包含同标识value值的: result3;
    __block NSMutableArray *validConDatas = [[NSMutableArray alloc] init];

    //b. 对result3进行取值value并排序: result4 (根据差的绝对值小的排前面);
    double pValue = [NUMTOOK([AINetIndex getData:maskValue_p]) doubleValue];
    NSArray *sortConDatas = [validConDatas sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        double v1 = [NUMTOOK([obj1 objectForKey:@"v"]) doubleValue];
        double v2 = [NUMTOOK([obj2 objectForKey:@"v"]) doubleValue];
        double absV1 = fabs(v1 - pValue);
        double absV2 = fabs(v2 - pValue);
        return absV1 > absV2 ? NSOrderedDescending : absV1 < absV2 ? NSOrderedAscending : NSOrderedSame;
    }];
    
    //c. 转成sortConAlgs
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *sortConData in sortConDatas) {
        AIAlgNodeBase *algNode = [sortConData objectForKey:@"a"];
        [result addObject:algNode];
    }
    return result;
}

@end
