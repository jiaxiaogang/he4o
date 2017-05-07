LKDBHelper-Transaction
======================

LKDBHelper 添加事物批处理


#import "BasePersistenceObject.h"

@interface class : BasePersistenceObject

@end

@implementation class

+(void)load{
    [[self class] registerTable];
}

+(int)getTableVersion{
    return 1;
}

@end
