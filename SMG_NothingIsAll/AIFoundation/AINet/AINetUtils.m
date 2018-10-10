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


+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:PATH_NET_CEREBEL_CANOUT fileName:FILENAME_Default time:cRedisDefaultTime]];
    NSString *identifier = STRFORMAT(@"%@_%@",algsType,dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:PATH_NET_CEREBEL_CANOUT fileName:FILENAME_Default time:cRedisDefaultTime];
    }
}

@end
