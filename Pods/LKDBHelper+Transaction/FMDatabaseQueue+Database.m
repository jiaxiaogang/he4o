//
//  FMDatabaseQueue+Database.m
//  mvoice
//
//  Created by yangjunhai on 14-7-12.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "FMDatabaseQueue+Database.h"
#import "FMDatabase.h"

@implementation FMDatabaseQueue (Database)

-(FMDatabase *)getDatabase{
#if DEBUG
    _db.traceExecution = YES;
#endif
    return _db;
}

@end
