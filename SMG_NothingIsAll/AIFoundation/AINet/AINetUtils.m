//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "AIAlgNode.h"
#import "AIAbsAlgNode.h"

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

//MARK:===============================================================
//MARK:                     < algTypeNodeUtils >
//MARK:===============================================================
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr{
    NSMutableArray *absAlgNodes = [[NSMutableArray alloc] init];
    for (AIKVPointer *alg_p in ARRTOOK(algsArr)) {
        AIAbsAlgNode *absNode = [[AIAbsAlgNode alloc] init];
        
        
        
        
    }
    return nil;
}

@end
