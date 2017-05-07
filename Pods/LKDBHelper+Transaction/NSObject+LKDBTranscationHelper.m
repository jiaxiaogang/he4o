//
//  NSObject+LKDBTranscationHelper.m 
//

#import "NSObject+LKDBTranscationHelper.h"
#import "LKDBTranscationHelper.h"


@implementation NSObject(LKDBTranscationHelper)

+(void)dbDidCreateTable:(LKDBTranscationHelper *)helper{}


#pragma mark - simplify synchronous function
+(BOOL)checkModelClass:(NSObject*)model
{
    if([model isMemberOfClass:self])
        return YES;
    
    NSLog(@"%@ can not use %@",NSStringFromClass(self),NSStringFromClass(model.class));
    return NO;
}

+(int)rowCount{
    return [[self getUsingLKDBHelper] rowCount:self where:nil];
}
+(NSMutableArray*)searchWithWhere:(id)where{
    return [[self getUsingLKDBHelper] search:self where:where orderBy:nil offset:0 count:0];
    
}
+(NSMutableArray*)searchWithWhere:(id)where orderBy:(NSString*)orderBy{
    return [[self getUsingLKDBHelper] search:self where:where orderBy:orderBy offset:0 count:0];

}
@end
