//
//  NSObject+Extension.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (PrintConvertDicOrJson)

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

- (void)getDic:(NSMutableDictionary *)outDic appendPropertyStringWithClass:(Class)clazz containParent:(BOOL)containParent {
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
