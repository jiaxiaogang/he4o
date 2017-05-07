//
//  LKDBTranscationHelper.h 
//

#import <Foundation/Foundation.h>
 
#import "LKDBHelper.h"
#import "NSObject+LKDBTranscationHelper.h"


@interface LKDBHelper(LKDBTranscationHelper)
 

@property(weak,nonatomic)FMDatabase* usingdb;
@property(strong,nonatomic)FMDatabaseQueue* bindingQueue;
 
- (BOOL)startTransaction;

- (BOOL)commitTransaction;

- (BOOL)rollbackTransaction;


-(NSMutableArray *)executeQuery:(NSString *)sql toClass:(Class)modelClass;


-(NSMutableArray *)executeQuery:(NSString *)sql;


- (NSMutableArray *)executeResult:(FMResultSet *)set Class:(Class)modelClass;
 

@end
