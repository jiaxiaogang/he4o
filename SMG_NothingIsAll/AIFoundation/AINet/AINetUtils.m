//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"

@implementation AINetUtils

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    NSArray *arr = [SMGUtils searchObjectForFilePath:PATH_NET_CEREBEL_CANOUT fileName:FILENAME_Default time:cRedisDefaultTime];
    return ARRISOK(arr) && [arr containsObject:STRFORMAT(@"%@_%@",algsType,dataSource)];
}

/**
 *  MARK:--------------------根据"分区和算法标识"查找引用节点的node_p地址--------------------
 *  @param limit : 最多少个
 *  @param algsType : 分区标识
 *  @param dataSource   : 算法标识
 */
//-(NSArray*) getNodePointersFromOutputReference:(NSString*)algsType dataSource:(NSString*)dataSource limit:(NSInteger)limit{
//    //1. 取mv分区的引用序列文件;
//    AIKVPointer *reference_p = [SMGUtils createPointerForCerebel:algsType dataSource:dataSource];
//    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime]];
//    
//    //2. 根据limit返回limit个结果;
//    if (ARRISOK(mArr)) {
//        limit = MAX(0, MIN(limit, mArr.count));
//        return [mArr subarrayWithRange:NSMakeRange(mArr.count - limit, limit)];
//    }
//    return nil;
//}

@end
