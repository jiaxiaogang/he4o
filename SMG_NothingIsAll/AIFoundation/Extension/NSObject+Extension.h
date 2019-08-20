//
//  NSObject+Extension.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < runtime >
//MARK:===============================================================
//@interface NSObject (runtime)
//
///* 获取对象的所有属性 */
//+(NSArray *)getAllProperties;
//
//
///* 获取对象的所有方法 */
//+(NSArray *)getAllMethods;
//
//
///* 获取对象的所有属性和属性内容 */
//+ (NSDictionary *)getAllPropertiesAndVaules:(NSObject *)obj;
//
//
//@end



//MARK:===============================================================
//MARK:                     < Invocation >
//MARK:===============================================================
//@interface NSObject (Invocation)
//
///*调用实例方法*/
//- (id)invocationMethodName:(NSString*)methodName withObjects:(NSArray *)objects;
//- (id)invocationSelector:(SEL)aSelector withObjects:(NSArray *)objects;
//
///*调用静态方法*/
//+ (id)invocationMethodName:(NSString*)methodName className:(NSString*)className withObjects:(NSArray *)objects;
//+ (id)invocationSelector:(SEL)aSelector class:(Class)class withObjects:(NSArray *)objects;
//
//@end



//MARK:===============================================================
//MARK:                     < Print转Dic或Json >
//MARK:===============================================================
@interface NSObject (PrintConvertDicOrJson)

//+ (void) dictionaryToEntity:(NSDictionary *)dict entity:(NSObject*)entity;              //DIC2Model
//+ (NSDictionary*)getDic:(id)obj;                                                        //Model2DIC
//+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;//Model2JSON

/**
 *  MARK:--------------------将obj转为dic类型--------------------
 *  @param containParent : 是否转换父类中的属性
 *  @result notnull
 */
+ (NSMutableDictionary*) getDic:(NSObject*)obj containParent:(BOOL)containParent;

@end
