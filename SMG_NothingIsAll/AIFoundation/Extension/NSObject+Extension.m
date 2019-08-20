//
//  NSObject+Extension.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>


//MARK:===============================================================
//MARK:                     < runtime >
//MARK:===============================================================
//@implementation NSObject (runtime)
//
//
///* 获取对象的所有属性 */
//+(NSArray *)getAllProperties
//{
//    u_int count;
//    // 传递count的地址过去 &count
//    objc_property_t *properties  =class_copyPropertyList([self class], &count);
//    //arrayWithCapacity的效率稍微高那么一丢丢
//    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
//
//    for (int i = 0; i < count ; i++)
//    {
//        //此刻得到的propertyName为c语言的字符串
//        const char* propertyName =property_getName(properties[i]);
//        //此步骤把c语言的字符串转换为OC的NSString
//        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
//    }
//    //class_copyPropertyList底层为C语言，所以我们一定要记得释放properties
//    // You must free the array with free().
//    free(properties);
//
//    return propertiesArray;
//}
//
//
//
///* 获取对象的所有方法 */
//+(NSArray *)getAllMethods
//{
//    unsigned int methodCount =0;
//    Method* methodList = class_copyMethodList([self class],&methodCount);
//    NSMutableArray *methodsArray = [NSMutableArray arrayWithCapacity:methodCount];
//
//    for(int i=0;i<methodCount;i++)
//    {
//        Method temp = methodList[i];
//        IMP imp = method_getImplementation(temp);
//        SEL name_f = method_getName(temp);
//        const char* name_s =sel_getName(method_getName(temp));
//        int arguments = method_getNumberOfArguments(temp);
//        const char* encoding =method_getTypeEncoding(temp);
//        NSLog(@"方法名：%@,参数个数：%d,编码方式：%@",[NSString stringWithUTF8String:name_s],
//              arguments,
//              [NSString stringWithUTF8String:encoding]);
//        [methodsArray addObject:[NSString stringWithUTF8String:name_s]];
//    }
//    free(methodList);
//    return methodsArray;
//}
//
//
///* 获取对象的所有属性和属性内容 */
//+ (NSDictionary *)getAllPropertiesAndVaules:(NSObject *)obj
//{
//    NSMutableDictionary *propsDic = [NSMutableDictionary dictionary];
//    unsigned int outCount;
//    objc_property_t *properties =class_copyPropertyList([obj class], &outCount);
//    for ( int i = 0; i<outCount; i++)
//    {
//        objc_property_t property = properties[i];
//        const char* char_f =property_getName(property);
//        NSString *propertyName = [NSString stringWithUTF8String:char_f];
//        id propertyValue = [obj valueForKey:(NSString *)propertyName];
//        if (propertyValue) {
//            [propsDic setObject:propertyValue forKey:propertyName];
//        }
//    }
//    free(properties);
//    return propsDic;
//}
//
//@end




//MARK:===============================================================
//MARK:                     < Invocation >
//MARK:===============================================================
//@implementation NSObject (Invocation)
//
//- (id)invocationMethodName:(NSString*)methodName withObjects:(NSArray *)objects{
//    SEL sel = NSSelectorFromString(methodName);
//    return [self invocationSelector:sel withObjects:objects];
//}
//
//- (id)invocationSelector:(SEL)aSelector withObjects:(NSArray *)objects {
//    //1. 取方法签名
//    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
//    
//    if (signature == nil) {
//        NSString * reason = [NSString stringWithFormat:@"- [%@ %@]:unrecognized selector sent to instance",
//                             self.class, NSStringFromSelector(aSelector)];
//        NSLog(@"Method doesn't exist.\n%@",reason);//@throw [[NSException alloc] initWithName:@"Method doesn't exist." reason:reason userInfo:nil];
//        return nil;
//    }
//    
//    //2. 根据methodSignature生成Invocation
//    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
//    invocation.target = self;
//    invocation.selector = aSelector;
//    
//    return [NSObject checkAndInvoke:invocation signature:signature objects:objects];
//}
//
//+ (id)invocationMethodName:(NSString*)methodName className:(NSString*)className withObjects:(NSArray *)objects{
//    Class clazz = NSClassFromString(className);
//    SEL sel = NSSelectorFromString(methodName);
//    return [self invocationSelector:sel class:clazz withObjects:objects];
//}
//
//+ (id)invocationSelector:(SEL)aSelector class:(Class)class withObjects:(NSArray *)objects{
//    //1. 取方法签名
//    if (class == NULL)
//        class = self.class;
//    NSMethodSignature *signature = [class methodSignatureForSelector:aSelector];
//    
//    if (signature == nil) {
//        NSString * reason = [NSString stringWithFormat:@"- [%@ %@]:unrecognized selector sent to instance",
//                             class, NSStringFromSelector(aSelector)];
//        NSLog(@"Method doesn't exist.\n%@",reason);//@throw [[NSException alloc] initWithName:@"Method doesn't exist." reason:reason userInfo:nil];
//        return nil;
//    }
//    
//    //2. 根据methodSignature生成Invocation
//    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
//    invocation.target = class;
//    invocation.selector = aSelector;
//    
//    return [self checkAndInvoke:invocation signature:signature objects:objects];
//}
//
//
///**
// *  MARK:--------------------1,检查参数 2,执行 3,返回result--------------------
// */
//+(id) checkAndInvoke:(NSInvocation*)invocation signature:(NSMethodSignature*)signature objects:(NSArray*)objects{
//    if (invocation == nil || signature == nil) {
//        return nil;
//    }
//    //3. 检查形实参个数取MIN(a,b)
//    NSUInteger argumentsCount = signature.numberOfArguments - 2;
//    NSUInteger objectsCount = objects.count;
//    NSUInteger count = MIN(argumentsCount, objectsCount);
//    for (int i = 0; i < count; i++) {
//        NSObject * obj = objects[i];
//        if ([obj isMemberOfClass:[NSObject class]]) {
//            obj = nil;
//        }
//        [invocation setArgument:&obj atIndex:i + 2];
//    }
//    
//    //4. invoke
//    [invocation invoke];
//    
//    //5. 返回值
//    const char *returnType = signature.methodReturnType;//获得返回值类型
//    id returnValue;
//    if( !strcmp(returnType, @encode(void)) ){//void
//        returnValue =  nil;
//    }else if( !strcmp(returnType, @encode(id)) ){//返回为对象
//        [invocation getReturnValue:&returnValue];
//    }else{//值类型
//        NSUInteger length = [signature methodReturnLength];
//        void *buffer = (void *)malloc(length);//根据长度申请内存
//        [invocation getReturnValue:buffer];//为变量赋值
//        
//        if( !strcmp(returnType, @encode(BOOL)) ) {
//            returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
//        }else if( !strcmp(returnType, @encode(NSInteger)) ){
//            returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
//        }else{
//            returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
//        }
//    }
//    
//    return returnValue;
//}
//
//@end



//MARK:===============================================================
//MARK:                     < Print转Dic或Json >
//MARK:===============================================================
@implementation NSObject (PrintConvertDicOrJson)

//+ (void) dictionaryToEntity:(NSDictionary *)dict entity:(NSObject*)entity {
//    if (dict && entity) {
//        for (NSString *keyName in [dict allKeys]) {
//            //构建出属性的set方法
//            NSString *destMethodName = [NSString stringWithFormat:@"set%@:",[keyName capitalizedString]]; //capitalizedString返回每个单词首字母大写的字符串（每个单词的其余字母转换为小写）
//            SEL destMethodSelector = NSSelectorFromString(destMethodName);
//            
//            if ([entity respondsToSelector:destMethodSelector]) {
//                [entity performSelector:destMethodSelector withObject:[dict objectForKey:keyName]];
//            }
//        }
//    }
//}
//
//+ (NSDictionary*)getDic:(id)obj {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    unsigned int propsCount;
//    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
//    for(int i = 0;i < propsCount; i++) {
//        objc_property_t prop = props[i];
//        id value = nil;
//        
//        @try {
//            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
//            value = [self getObjectInternal:[obj valueForKey:propName]];
//            if(value != nil) {
//                [dic setObject:value forKey:propName];
//            }
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@",exception);
//        }
//        
//    }
//    return dic;
//}
//
//
//+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error
//{
//    return [NSJSONSerialization dataWithJSONObject:[self getDic:obj] options:options error:error];
//    
//}
//
//+ (id)getObjectInternal:(id)obj
//{
//    if(!obj
//       || [obj isKindOfClass:[NSString class]]
//       || [obj isKindOfClass:[NSNumber class]]
//       || [obj isKindOfClass:[NSNull class]]) {
//        return obj;
//    }
//    
//    if([obj isKindOfClass:[NSArray class]]) {
//        NSArray *objarr = obj;
//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
//        for(int i = 0;i < objarr.count; i++) {
//            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
//        }
//        return arr;
//    }
//    
//    if([obj isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *objdic = obj;
//        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
//        for(NSString *key in objdic.allKeys) {
//            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
//        }
//        return dic;
//    }
//    return [self getDic:obj];
//}

/**
 *  MARK:--------------------引自LKDB中LKModel--------------------
 */
+ (NSMutableDictionary*) getDic:(NSObject*)obj containParent:(BOOL)containParent{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    if (obj) {
        [obj getDic:mDic appendPropertyStringWithClass:obj.class containParent:containParent];
    }
    return mDic;
}

- (void)getDic:(NSMutableDictionary *)outDic appendPropertyStringWithClass:(Class)clazz containParent:(BOOL)containParent
{
    if (clazz == [NSObject class] || outDic == nil) {
        return;
    }
    unsigned int outCount = 0, i = 0;
    objc_property_t *properties = class_copyPropertyList(clazz, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [outDic setObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(properties);
    if (containParent) {
        [self getDic:outDic appendPropertyStringWithClass:clazz.superclass containParent:containParent];
    }
}

@end
