//
//  DYPersistenceObject.m 
//

#import "DYPersistenceObject.h"
#import "LKDBTranscationHelper.h"
#import <objc/runtime.h> 

#define DEFAULT_ERROR_TABLE_VERSION -1

@implementation DYPersistenceObject



//在类 初始化的时候
+(void)initialize
{
    //remove unwant property
    for (NSString *property in [[self class] transients]) {
        [self removePropertyWithColumnName:property];
    }
    
} 

+ (void)registerTable{
#if DEBUG
    NSArray *validateError = [[self class] validateFields:[self class]];;
    if (validateError != nil) {
        NSException *e = [[NSException alloc] initWithName:@"class define error!" reason:[validateError componentsJoinedByString:@"\n"] userInfo:nil];
        @throw e;
    }
#endif
    [[self getUsingLKDBHelper] createTableWithModelClass:[self class]];
}

#if DEBUG
// 将要插入数据库
+(BOOL)dbWillInsert:(NSObject *)entity
{
    NSArray *validateError = [[self class] validate:entity];
    if (validateError != nil) {
        NSException *e = [[NSException alloc] initWithName:@"data type error!" reason:[validateError componentsJoinedByString:@"\n"] userInfo:nil];
        @throw e;
    }
    return YES;
}
// 将要更新数据库
+(BOOL)dbWillUpdate:(NSObject *)entity
{
    NSArray *validateError = [[self class] validate:entity];
    if (validateError != nil) { 
        NSException *e = [[NSException alloc] initWithName:@"data type error!" reason:[validateError componentsJoinedByString:@"\n"] userInfo:nil];
        @throw e;
    }
    return YES;
}
+(int)getTableVersion{
    return DEFAULT_ERROR_TABLE_VERSION;
}

#endif

+ (NSArray *)transients{
    return nil;
}

+ (NSString*) getTableName
{
    return [self nameFilter:[NSString stringWithUTF8String:class_getName([self class])]];
}
+ (NSString *)nameFilter:(NSString *)name
{
    NSMutableString *ret = [NSMutableString string];
    
	for (int i = 0; i < name.length; i++)
	{
		NSRange range = NSMakeRange(i, 1);
		NSString *oneChar = [name substringWithRange:range];
		if ([oneChar isEqualToString:[oneChar uppercaseString]] && i > 0)
			[ret appendFormat:@"_%@", [oneChar lowercaseString]];
		else
			[ret appendString:[oneChar lowercaseString]];
	}
    
    return ret;
} 


+ (id)loadByRowid:(int)_rowid{
    return [[self getUsingLKDBHelper] searchSingle:[self class] where:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_rowid],@"rowid", nil] orderBy:nil];
}

- (id)loadByRowid{
    return [[[self class] getUsingLKDBHelper] searchSingle:[self class] where:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.rowid],@"rowid", nil] orderBy:nil];
}

- (NSArray *)execQuery:(NSString *)sql{
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    return [manager execQuery:[self class] sql:sql];
}

- (id)execQuerySingle:(NSString *)sql{
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    NSArray *result =  [manager execQuery:[self class] sql:sql];
    if(result.count>0){
        return [result objectAtIndex:0];
    }
    
    return nil;
}


+ (NSArray *)list{
    return [[self class] searchWithWhere:nil];
}

+ (int)count{
   return  [[self class] rowCount];
}

+ (void)drop{
    
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    
    [manager drop:[self class]];
     
}

- (NSInteger)save{
    
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    
    if(self.rowid>0){
        [manager update:self];
    }else{
        [manager insert:self];
    }
    
    return self.rowid;
}

- (NSInteger)update{
    
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    
    [manager update:self];
    
    return self.rowid;
}

- (void)delete{
    
    DYPersistenceManager *manager = [DYPersistenceManager sharedManager];
    
    [manager delete:self];
    
}

+ (NSDictionary *)fields:(Class)class
{
    // Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
	NSMutableDictionary *theProps;
	
	if ([class superclass] != [NSObject class])
		theProps = (NSMutableDictionary *)[[self class] fields:[class superclass]];
	else
		theProps = [NSMutableDictionary dictionary];
	
	unsigned int outCount;
    
    objc_property_t *propList = class_copyPropertyList(class, &outCount);
    
    // Loop through properties and add declarations for the create
	for (int i=0; i < outCount; i++)
	{
        objc_property_t oneProp = propList[i];
        
		NSString *propName = [NSString stringWithUTF8String:property_getName(oneProp)];
		NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(oneProp)];
        
        
        // Read only attributes are assumed to be derived or calculated
		if ([attrs rangeOfString:@",R,"].location == NSNotFound)
		{
			NSArray *attrParts = [attrs componentsSeparatedByString:@","];
			if (attrParts != nil)
			{
				if ([attrParts count] > 0)
				{
					NSString *propType = [[attrParts objectAtIndex:0] substringFromIndex:1];
					[theProps setObject:propType forKey:propName];
				}
			}
		}
    }
    
    free(propList);
    
    return theProps;
}

+ (NSMutableArray *)validateFields:(Class)class
{
    // Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
    
    objc_property_t *propList;
    
    NSMutableArray *error=[[NSMutableArray alloc] init];
    [error addObject:[[NSMutableString alloc] initWithString:@"\n===============================对象定义错误========================================="]];
    [error addObject:[@"对象:" stringByAppendingString:[NSString stringWithUTF8String:class_getName(class)]]];
    
    @try {
        NSMutableDictionary *theProps;
        if ([class superclass] != [NSObject class])
            theProps = (NSMutableDictionary *)[[self class] fields:[class superclass]];
        else
            theProps = [NSMutableDictionary dictionary];
        
        unsigned int outCount;
        
        propList = class_copyPropertyList(class, &outCount);
        
        int version  = [class getTableVersion];
        if(version==DEFAULT_ERROR_TABLE_VERSION){
            
            NSMutableString *string=[[NSMutableString alloc] init];
            [string appendString:@"表版本方法 +(int)getTableVersion  需要定义\n"];
            [error addObject:string];
        }
        
        // Loop through properties and add declarations for the create
        for (int i=0; i < outCount; i++)
        {
            objc_property_t oneProp = propList[i];
            
            NSString *propName = [NSString stringWithUTF8String:property_getName(oneProp)];
            NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(oneProp)];
            
            // Read only attributes are assumed to be derived or calculated
            if ([attrs rangeOfString:@",R,"].location == NSNotFound)
            {
                
                if ([attrs rangeOfString:@"@"].location != NSNotFound){
                    if ([attrs rangeOfString:@"&"].location == NSNotFound){
                        NSMutableString *string=[[NSMutableString alloc] init];
                        [string appendString:@"参数 ["];
                        [string appendString:propName];
                        [string appendString:@"]: 类型错误 ,需要使用 strong 而不是 assgin"];
                        [error addObject:string];
                    }
                }else{
                    if ([attrs rangeOfString:@"&"].location != NSNotFound){
                        NSMutableString *string=[[NSMutableString alloc] init];
                        [string appendString:@"参数 ["];
                        [string appendString:propName];
                        [string appendString:@"]: 类型错误 ,需要使用 assgin 而不是 strong"];
                        [error addObject:string];
                    }
                    
                }
                
                
            }
        }
        
    }
    @catch (NSException *exception) {
        [error addObject:[[exception callStackSymbols] componentsJoinedByString:@"\n"]];
    }@finally {
        if(propList)
            free(propList);
    }
    [error addObject:[[NSMutableString alloc] initWithString:@"\n========================================================================"]];
    if(error.count>3)
        return error;
    else {
        return nil;
    }
}


+ (NSMutableArray *)validate:(DYPersistenceObject *)object
{
    
    LKModelInfos* infos = [[object class] getModelInfos];
    
    NSMutableArray *error=[[NSMutableArray alloc] init];
    [error addObject:[[NSMutableString alloc] initWithString:@"\n===============================数据与对象不匹配========================================="]];
    [error addObject:[[@"表名:" stringByAppendingString:[[object class] getTableName]] stringByAppendingString:@"\n\n"]];
    
    @try {
        for(int i=0;i<infos.count;i++){
            LKDBProperty *property =[infos objectWithIndex:i];
            
            NSString *propType = property.propertyType;
            NSString *propertyName = property.propertyName;
            
            id value = [object valueForKey:propertyName];
            
            
            if([value isKindOfClass:[NSNull class]]||value==nil)
                continue;
            
            if([propType isEqualToString:@"NSString"])
            {
                if([value isKindOfClass:[NSString class]])
                    continue;
            }else if([propType isEqualToString:@"NSData"])
            {
                if([value isKindOfClass:[NSData class]])
                    continue;
            }else if([propType isEqualToString:@"NSDate"])
            {
                if([value isKindOfClass:[NSDate class]])
                    continue;
            }else if([propType isEqualToString:@"NSNumber"])
            {
                if([value isKindOfClass:[NSNumber class]])
                    continue;
            }else
            {
                    continue;
            }
            
            NSString *valueClassName=[NSString stringWithUTF8String:class_getName([value class])];
             
            NSMutableString *string=[[NSMutableString alloc] init];
            [string appendString:@"错误参数 ["];
            [string appendString:propertyName];
            [string appendString:@"]: 对象中错误的数据类型 "];
            [string appendString:@"["];
            [string appendString:valueClassName];
            [string appendString:@"], 实际需要的数据类型为实现或继承 "];
            [string appendString:@"["];
            [string appendString:propType];
            [string appendString:@"] Class的对象!"];
            [error addObject:string];
            
            
        }
    }
    @catch (NSException *exception) {
        [error addObject:[[exception callStackSymbols] componentsJoinedByString:@"\n"]];
    }
    [error addObject:[[NSMutableString alloc] initWithString:@"\n========================================================================"]];
    if(error.count>3)
        return error;
    else {
        return nil;
    }
}



@end
