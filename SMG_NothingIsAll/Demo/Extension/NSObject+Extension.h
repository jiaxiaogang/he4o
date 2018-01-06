//
//  NSObject+Extension.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (Extension)

-(id) content;

@end


//MARK:===============================================================
//MARK:                     < runtime >
//MARK:===============================================================
@interface NSObject (runtime)

/* 获取对象的所有属性 */
+(NSArray *)getAllProperties;


/* 获取对象的所有方法 */
+(NSArray *)getAllMethods;


/* 获取对象的所有属性和属性内容 */
+ (NSDictionary *)getAllPropertiesAndVaules:(NSObject *)obj;


@end



//MARK:===============================================================
//MARK:                     < Invocation >
//MARK:===============================================================
@interface NSObject (Invocation)

- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects;
+ (id)performSelector:(SEL)aSelector class:(Class)class withObjects:(NSArray *)objects;

@end
