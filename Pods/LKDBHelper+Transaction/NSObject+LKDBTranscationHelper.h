//
//  NSObject+LKDBTranscationHelper.h 
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"

@class LKDBTranscationHelper;
@interface NSObject(LKDBTranscationHelper)

//callback delegate
+(void)dbDidCreateTable:(LKDBTranscationHelper*)helper;


+(int)rowCount;


+(NSMutableArray*)searchWithWhere:(id)where;

+(NSMutableArray*)searchWithWhere:(id)where orderBy:(NSString*)orderBy;

 

@end