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

+(AITargetType) getTargetType:(MVType)type;

//cmvAlgsArr->mvValue
+(void) parserAlgsMVArr:(NSArray*)algsArr success:(void(^)(NSInteger delta,NSInteger urgentTo,NSString *algsType))success;
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success;

@end
