//
//  DYPersistenceManager.m
//  mvoice
//
//  Created by yangjunhai on 14-7-13.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "DYPersistenceManager.h"
#import "LKDBTranscationHelper.h"
#import "DYPersistenceObject.h"

@implementation DYPersistenceManager


+ (DYPersistenceManager *)sharedManager {
    static DYPersistenceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DYPersistenceManager alloc] init];
        // Do any other initialisation stuff here
    });
    
    return sharedInstance;
} 


- (BOOL)startTransaction{
    return [[LKDBHelper getUsingLKDBHelper] startTransaction];
}

- (BOOL)commitTransaction{
    return [[LKDBHelper getUsingLKDBHelper] commitTransaction];
}

- (BOOL)rollbackTransaction{
    return [[LKDBHelper getUsingLKDBHelper] rollbackTransaction];
}

- (BOOL)execSQL:(NSString *)sql{
    return [[LKDBHelper getUsingLKDBHelper]  executeSQL:sql arguments:nil];
}

- (NSInteger)insert:(DYPersistenceObject *)object{
    [[LKDBHelper getUsingLKDBHelper]  insertToDB:object];
    return object.rowid;
}

- (NSInteger)update:(DYPersistenceObject *)object{
    [[LKDBHelper getUsingLKDBHelper] updateToDB:object where:@{@"rowid":[NSNumber numberWithInt:object.rowid]}];
    return object.rowid;
}

- (void)delete:(DYPersistenceObject *)object{
    [[LKDBHelper getUsingLKDBHelper]  deleteToDB:object];

}

- (void)drop:(Class)class{
    [[LKDBHelper getUsingLKDBHelper] dropTableWithClass:class];
}

- (NSArray *)execQuery:(NSString *)sql{
    return [[LKDBHelper getUsingLKDBHelper]  executeQuery:sql];
}

- (NSArray *)execQuery:(Class)class sql:(NSString *)sql{ 

    return [[LKDBHelper getUsingLKDBHelper]  executeQuery:sql toClass:class];
}

@end
