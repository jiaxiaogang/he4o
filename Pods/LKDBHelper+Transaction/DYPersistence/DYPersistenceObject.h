//
//  DYPersistenceObject.h 
//

#import <Foundation/Foundation.h>
#import "DYPersistenceManager.h"
#import "LKDBTranscationHelper.h"
 

@interface DYPersistenceObject : NSObject 

/**
 +(void)load{
    [[self class] registerTable];
 }
 */
+ (void)registerTable;

+ (NSString*) getTableName;
 

+ (NSArray *)transients;  //忽略的字段


+ (id)loadByRowid:(int)_rowid;

- (id)loadByRowid;

- (NSArray *)execQuery:(NSString *)sql;

- (id)execQuerySingle:(NSString *)sql;
 
+ (NSArray *)list;

+ (int)count; 

- (int)save;

- (int)update;

- (void)delete;


@end
