//
//  LKDBTranscationHelper.m
//

#import "LKDBTranscationHelper.h"
#import "FMDatabaseQueue+Database.h" 
#import "FMDatabase.h"

 

@implementation LKDBHelper(LKDBTranscationHelper)


- (BOOL)startTransaction{
    
    self.usingdb = [self.bindingQueue getDatabase];
    BOOL result = [self.usingdb beginTransaction];
    return result;
}

- (BOOL)commitTransaction{
    BOOL result =  [self.usingdb commit];
    return result;
}

- (BOOL)rollbackTransaction{
    BOOL result = [self.usingdb rollback];
    return result;
}

-(NSMutableArray *)executeQuery:(NSString *)executeSQL toClass:(Class)modelClass
{
    
    __block NSMutableArray* results = nil;
    [self executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:executeSQL];
        results = [self executeResult:set Class:modelClass];
        [set close];
    }];
    return results;
}

-(NSMutableArray *)executeQuery:(NSString *)executeSQL
{
    
    __block NSMutableArray* results = nil;
    [self executeDB:^(FMDatabase *db) {
        FMResultSet* set = [db executeQuery:executeSQL];
        results = [self executeResult:set];
        [set close];
    }];
    return results;
}

- (NSMutableArray *)executeResult:(FMResultSet *)set
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    int columnCount = [set columnCount];
    while ([set next]) {
        
        NSMutableDictionary* bindingModel = [[NSMutableDictionary alloc]init];
        
        for (int i=0; i<columnCount; i++) {
            
            NSString* sqlName = [set columnNameForIndex:i];
            NSObject* sqlValue = [set objectForColumnIndex:i];
            
            [bindingModel setObject:sqlValue forKey:sqlName];
        }
        [array addObject:bindingModel];
    }
    return array;
}
  
@end
