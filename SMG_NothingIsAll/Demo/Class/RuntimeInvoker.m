//
//  RuntimeInvoker.m
//  RuntimeInvoker
//
//  Created by cyan on 16/5/27.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "RuntimeInvoker.h"
#import <UIKit/UIKit.h>

#define _DEFINE_ARRAY(arg) \
NSMutableArray *array = [NSMutableArray arrayWithObject:arg];\
va_list args;\
va_start(args, arg);\
id next = nil;\
while ((next = va_arg(args,id))) {\
    [array addObject:next];\
}\
va_end(args);\

#pragma mark - NSMethodSignature Category

//  Objective-C type encoding: http://nshipster.com/type-encodings/
typedef NS_ENUM(NSInteger, RIMethodArgumentType) {
    RIMethodArgumentTypeUnknown             = 0,
    RIMethodArgumentTypeChar,
    RIMethodArgumentTypeInt,
    RIMethodArgumentTypeShort,
    RIMethodArgumentTypeLong,
    RIMethodArgumentTypeLongLong,
    RIMethodArgumentTypeUnsignedChar,
    RIMethodArgumentTypeUnsignedInt,
    RIMethodArgumentTypeUnsignedShort,
    RIMethodArgumentTypeUnsignedLong,
    RIMethodArgumentTypeUnsignedLongLong,
    RIMethodArgumentTypeFloat,
    RIMethodArgumentTypeDouble,
    RIMethodArgumentTypeBool,
    RIMethodArgumentTypeVoid,
    RIMethodArgumentTypeCharacterString,
    RIMethodArgumentTypeCGPoint,
    RIMethodArgumentTypeCGSize,
    RIMethodArgumentTypeCGRect,
    RIMethodArgumentTypeUIEdgeInsets,
    RIMethodArgumentTypeObject,
    RIMethodArgumentTypeClass,
    RIMethodArgumentTypeSEL,
    RIMethodArgumentTypeIMP,
};

@implementation NSMethodSignature (RuntimeInvoker)

/**
 *  Get type of return value
 *
 *  @return Return value type
 */
- (RIMethodArgumentType)returnType {
    return [NSMethodSignature argumentTypeWithEncode:[self methodReturnType]];
}

/**
 *  Type encoding for argument
 *
 *  @param encode Encode for argument
 *
 *  @return RIMethodArgumentType
 */
+ (RIMethodArgumentType)argumentTypeWithEncode:(const char *)encode {
    
    if (strcmp(encode, @encode(char)) == 0) {
        return RIMethodArgumentTypeChar;
    } else if (strcmp(encode, @encode(int)) == 0) {
        return RIMethodArgumentTypeInt;
    } else if (strcmp(encode, @encode(short)) == 0) {
        return RIMethodArgumentTypeShort;
    } else if (strcmp(encode, @encode(long)) == 0) {
        return RIMethodArgumentTypeLong;
    } else if (strcmp(encode, @encode(long long)) == 0) {
        return RIMethodArgumentTypeLongLong;
    } else if (strcmp(encode, @encode(unsigned char)) == 0) {
        return RIMethodArgumentTypeUnsignedChar;
    } else if (strcmp(encode, @encode(unsigned int)) == 0) {
        return RIMethodArgumentTypeUnsignedInt;
    } else if (strcmp(encode, @encode(unsigned short)) == 0) {
        return RIMethodArgumentTypeUnsignedShort;
    } else if (strcmp(encode, @encode(unsigned long)) == 0) {
        return RIMethodArgumentTypeUnsignedLong;
    } else if (strcmp(encode, @encode(unsigned long long)) == 0) {
        return RIMethodArgumentTypeUnsignedLongLong;
    } else if (strcmp(encode, @encode(float)) == 0) {
        return RIMethodArgumentTypeFloat;
    } else if (strcmp(encode, @encode(double)) == 0) {
        return RIMethodArgumentTypeDouble;
    } else if (strcmp(encode, @encode(BOOL)) == 0) {
        return RIMethodArgumentTypeBool;
    } else if (strcmp(encode, @encode(void)) == 0) {
        return RIMethodArgumentTypeVoid;
    } else if (strcmp(encode, @encode(char *)) == 0) {
        return RIMethodArgumentTypeCharacterString;
    } else if (strcmp(encode, @encode(id)) == 0) {
        return RIMethodArgumentTypeObject;
    } else if (strcmp(encode, @encode(Class)) == 0) {
        return RIMethodArgumentTypeClass;
    } else if (strcmp(encode, @encode(CGPoint)) == 0) {
        return RIMethodArgumentTypeCGPoint;
    } else if (strcmp(encode, @encode(CGSize)) == 0) {
        return RIMethodArgumentTypeCGSize;
    } else if (strcmp(encode, @encode(CGRect)) == 0) {
        return RIMethodArgumentTypeCGRect;
    } else if (strcmp(encode, @encode(UIEdgeInsets)) == 0) {
        return RIMethodArgumentTypeUIEdgeInsets;
    } else if (strcmp(encode, @encode(SEL)) == 0) {
        return RIMethodArgumentTypeSEL;
    }  else if (strcmp(encode, @encode(IMP))) {
        return RIMethodArgumentTypeIMP;
    } else {
        return RIMethodArgumentTypeUnknown;
    }
}

/**
 *  Get type of argument at index
 *
 *  @param index Argument index
 *
 *  @return Return value type
 */
- (RIMethodArgumentType)argumentTypeAtIndex:(NSInteger)index {
    const char *encode = [self getArgumentTypeAtIndex:index];
    return [NSMethodSignature argumentTypeWithEncode:encode];
}

/**
 *  Setup arguments for invocation
 *
 *  @param arguments Arguments
 *
 *  @return NSInvocation
 */
- (NSInvocation *)invocationWithArguments:(NSArray *)arguments {
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self];
    
    NSAssert(arguments == nil || [arguments isKindOfClass:[NSArray class]], @"# RuntimeInvoker # arguments is not an array");
    
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull argument, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger index = idx + 2; // start with 2
        RIMethodArgumentType type = [self argumentTypeAtIndex:index];
        
        switch (type) {
            case RIMethodArgumentTypeChar: {
                char value = [argument charValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeInt: {
                int value = [argument intValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeShort: {
                short value = [argument shortValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeLong: {
                long value = [argument longValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeLongLong: {
                long long value = [argument longLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeUnsignedChar: {
                unsigned char value = [argument unsignedCharValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeUnsignedInt: {
                unsigned int value = [argument unsignedIntValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeUnsignedShort: {
                unsigned short value = [argument unsignedShortValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeUnsignedLong: {
                unsigned long value = [argument unsignedLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeUnsignedLongLong: {
                unsigned long long value = [argument unsignedLongLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeFloat: {
                float value = [argument floatValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeDouble: {
                double value = [argument doubleValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeBool: {
                BOOL value = [argument boolValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeVoid: {
                
            } break;
            case RIMethodArgumentTypeCharacterString: {
                const char *value = [argument UTF8String];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeObject: {
                [invocation setArgument:&argument atIndex:index];
            } break;
            case RIMethodArgumentTypeClass: {
                Class value = [argument class];
                [invocation setArgument:&value atIndex:index];
            } break;
            case RIMethodArgumentTypeIMP: {
                IMP imp = [argument pointerValue];
                [invocation setArgument:&imp atIndex:index];
            } break;
            case RIMethodArgumentTypeSEL: {
                SEL sel = [argument pointerValue];
                [invocation setArgument:&sel atIndex:index];
            } break;
                
            default: break;
        }
    }];
    
    return invocation;
}

@end

#pragma mark - NSInvocation Category

@implementation NSInvocation (RuntimeInvoker)

/**
 *  Invoke a selector
 *
 *  @param target   Target
 *  @param selector Selector
 *  @param type     Return value type
 *
 *  @return Return value
 */
- (id)invoke:(id)target selector:(SEL)selector returnType:(RIMethodArgumentType)type {
    self.target = target;
    self.selector = selector;
    [self invoke];
    return [self returnValueForType:type];
}

/**
 *  Boxing returnType of NSMethodSignature
 *
 *  @param type Signature
 *
 *  @return Boxed value
 */
- (id)returnValueForType:(RIMethodArgumentType)type {
    
    __unsafe_unretained id returnValue;
    
    switch (type) {
        case RIMethodArgumentTypeChar: {
            char value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeInt:  {
            int value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeShort:  {
            short value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeLong:  {
            long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeLongLong:  {
            long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeUnsignedChar:  {
            unsigned char value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeUnsignedInt:  {
            unsigned int value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeUnsignedShort:  {
            unsigned short value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeUnsignedLong:  {
            unsigned long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeUnsignedLongLong:  {
            unsigned long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeFloat:  {
            float value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeDouble:  {
            double value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeBool: {
            BOOL value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case RIMethodArgumentTypeCharacterString: {
            const char *value;
            [self getReturnValue:&value];
            returnValue = [NSString stringWithUTF8String:value];
        } break;
        case RIMethodArgumentTypeCGPoint: {
            CGPoint value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGPoint:value];
        } break;
        case RIMethodArgumentTypeCGSize: {
            CGSize value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGSize:value];
        } break;
        case RIMethodArgumentTypeCGRect: {
            CGRect value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGRect:value];
        } break;
        case RIMethodArgumentTypeUIEdgeInsets: {
            UIEdgeInsets value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithUIEdgeInsets:value];
        } break;
        case RIMethodArgumentTypeSEL: {
            SEL sel;
            [self getReturnValue:&sel];
            returnValue = [NSValue valueWithPointer:sel];
        } break;
        case RIMethodArgumentTypeIMP: {
            IMP imp;
            [self getReturnValue:&imp];
            returnValue = [NSValue valueWithPointer:imp];
        } break;
        case RIMethodArgumentTypeObject:
        case RIMethodArgumentTypeClass:
            [self getReturnValue:&returnValue];
            break;
        default: break;
    }
    return returnValue;
}

@end

#pragma mark - NSObject Category

@implementation NSObject (RuntimeInvoker)

id _invoke(id target, NSString *selector, NSArray *arguments) {
    SEL sel = NSSelectorFromString(selector);
    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
    if (signature) {
        NSInvocation *invocation = [signature invocationWithArguments:arguments];
        id returnValue = [invocation invoke:target selector:sel returnType:signature.returnType];
        return returnValue;
    } else {
        NSLog(@"# RuntimeInvoker # selector: \"%@\" NOT FOUND", selector);
        return nil;
    }
}

- (id)invoke:(NSString *)selector arguments:(NSArray *)arguments {
    return _invoke(self, selector, arguments);
}

- (id)invoke:(NSString *)selector {
    return [self invoke:selector arguments:nil];
}

- (id)invoke:(NSString *)selector args:(id)arg, ... {
    _DEFINE_ARRAY(arg);
    return [self invoke:selector arguments:array];
}

+ (id)invoke:(NSString *)selector {
    return [self.class invoke:selector arguments:nil];
}

+ (id)invoke:(NSString *)selector args:(id)arg, ... {
    _DEFINE_ARRAY(arg);
    return [self.class invoke:selector arguments:array];
}

+ (id)invoke:(NSString *)selector arguments:(NSArray *)arguments {
    return _invoke(self.class, selector, arguments);
}

@end

@implementation NSString (RuntimeInvoker)

- (id)invokeClassMethod:(NSString *)selector {
    return [self invokeClassMethod:selector arguments:nil];
}

- (id)invokeClassMethod:(NSString *)selector args:(id)arg, ... {
    _DEFINE_ARRAY(arg);
    return [self invokeClassMethod:selector arguments:array];
}

- (id)invokeClassMethod:(NSString *)selector arguments:(NSArray *)arguments {
    return [NSClassFromString(self) invoke:selector arguments:arguments];
}

@end
