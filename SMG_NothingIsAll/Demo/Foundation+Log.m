//
//  Foundation+Log.m
//
//  Created by feiyujie on 2016/12/7.
//  Copyright © 2016年 feiyujie. All rights reserved.
//

#ifdef DEBUG

#import <Foundation/Foundation.h>

static NSInteger dictionaryTabCount = 0;
static NSInteger arrayTabCount = 0;
static NSInteger setTabCount = 0;

@implementation NSArray(Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self yj_description:++arrayTabCount];
    arrayTabCount = 0;
    return logStr;
}

- (NSString *)yj_description:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];
    
    [logStr appendFormat:@"(\n"];
    
    NSInteger arrayLength = self.count;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i = 1; i <= depth; ++i) {
            [logStr appendFormat:@"\t"];
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            if (idx != arrayLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
            arrayTabCount = depth;
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            dictionaryTabCount = depth;
            if (idx != arrayLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
        } else if ([obj isKindOfClass:[NSSet class]]) {
            setTabCount = depth;
            if (idx != arrayLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
            
        } else {
            if (idx != arrayLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
        }
        
    }];
    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }
    [logStr appendFormat:@")"];
    
    return logStr;
}

@end;

@implementation NSDictionary(Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self yj_description:++dictionaryTabCount];
    dictionaryTabCount = 0;
    return logStr;
}

- (NSString *)yj_description:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];
    
    [logStr appendFormat:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        for (NSInteger i = 1; i <= depth; ++i) {
            [logStr appendFormat:@"\t"];
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            arrayTabCount = depth;
            [logStr appendFormat:@"%@ =\t%@;\n", key, obj];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            [logStr appendFormat:@"%@ =\t%@;\n", key, obj];
            dictionaryTabCount = depth;
        } else if ([obj isKindOfClass:[NSSet class]]) {
            setTabCount = depth;
            [logStr appendFormat:@"%@ =\t%@;\n", key, obj];
        } else {
            [logStr appendFormat:@"%@ = %@;\n", key, obj];
        }
    }];
    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }
    [logStr appendFormat:@"}"];
    
    return logStr;
}

@end

@implementation NSSet(Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self yj_description:++setTabCount];
    setTabCount = 0;
    return logStr;
}

- (NSString *)yj_description:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];
    
    [logStr appendFormat:@"{(\n"];
    
    NSInteger setLength = self.count;
    
    __block NSInteger idx = 0;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        for (NSInteger i = 1; i <= depth; ++i) {
            [logStr appendFormat:@"\t"];
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            arrayTabCount = depth;
            if (idx != setLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            dictionaryTabCount = depth;
            if (idx != setLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
        } else if ([obj isKindOfClass:[NSSet class]]) {
            if (idx != setLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
            setTabCount = depth;
        } else {
            if (idx != setLength - 1) {
                [logStr appendFormat:@"%@,\n", obj];
            } else {
                [logStr appendFormat:@"%@\n", obj];
            }
        }
        ++idx;
        
    }];
    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }
    [logStr appendFormat:@")}"];
    
    return logStr;
}

@end

#endif
