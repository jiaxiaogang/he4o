//
//  ThinkingUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThinkingUtils : NSObject

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@interface ThinkingUtils (Analogy)

+(BOOL) analogyCharA:(char)a b:(char)b;

+(void) analogyCMVA:(NSArray*)a b:(NSArray*)b;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (CMV) >
//MARK:===============================================================
@interface ThinkingUtils (CMV)

//取mvType或algsType对应的targetType
+(AITargetType) getTargetType:(MVType)type;
+(AITargetType) getTargetTypeWithAlgsType:(NSString*)algsType;


//解析algsMVArr
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success;
+(void) parserAlgsMVArr:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSInteger delta,NSInteger urgentTo,NSString *algsType))success;

@end
