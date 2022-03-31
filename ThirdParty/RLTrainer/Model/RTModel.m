//
//  RTModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RTModel.h"

@interface RTModel ()

@property (strong, nonatomic) NSMutableDictionary *dic;

@end

@implementation RTModel

//MARK:===============================================================
//MARK:                     < getset >
//MARK:===============================================================
-(NSMutableDictionary*)dic {
    if (!_dic) {
        _dic = [[NSMutableDictionary alloc] init];
    }
    return _dic;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector{
    
    //1. 获得类和方法的签名
    NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
    
    //2. 反射器;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    //3. 从签名获得调用对象
    [invocation setTarget:target];
    invocation.target = target;
    invocation.selector = selector;
    
    //4. 收集备用;
    [self.dic setObject:invocation forKey:name];
}

-(void) invoke:(NSString*)name{
    NSInvocation *invc = [self.dic objectForKey:name];
    [invc invoke];
}

@end
