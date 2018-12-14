//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"

@implementation AINetUtils

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    return ARRISOK(arr) && [arr containsObject:STRFORMAT(@"%@_%@",algsType,dataSource)];
}


+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime]];
    NSString *identifier = STRFORMAT(@"%@_%@",algsType,dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    }
}


+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 有则强度+1;
        for (AIPort *port in ports) {
            if ([pointer isEqual:port.target_p]) {
                port.strong.value ++;
                return;
            }
        }

        //2. 无则追加新port;
        AIPort *port = [[AIPort alloc] init];
        port.target_p = pointer;
        [ports addObject:port];
    }
}

@end
