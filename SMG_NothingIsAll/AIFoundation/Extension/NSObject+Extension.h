//
//  NSObject+Extension.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < Invocation >
//MARK:===============================================================
@interface NSObject (Invocation)

/*调用静态方法*/
+ (id)invocationMethodName:(NSString*)methodName className:(NSString*)className withObjects:(NSArray *)objects;
+ (id)invocationSelector:(SEL)aSelector class:(Class)class withObjects:(NSArray *)objects;

@end



//MARK:===============================================================
//MARK:                     < Print转Dic或Json >
//MARK:===============================================================
@interface NSObject (PrintConvertDicOrJson)

+ (NSDictionary*)getDic:(id)obj;                                                        //Model2DIC
+ (NSDictionary*) getDic:(NSObject*)obj containParent:(BOOL)containParent;

@end
