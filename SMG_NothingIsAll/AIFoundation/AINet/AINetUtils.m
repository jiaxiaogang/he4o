//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"

@implementation AINetUtils

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource{
    AIKVPointer *reference_p = [SMGUtils createPointerForCerebel:algsType dataSource:dataSource];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime]];
    return ARRISOK(mArr);
}

@end
