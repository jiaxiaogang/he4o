//
//  AITest.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/9/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AITest : NSObject

+(void) test1:(NSString*)aDS hnAlgDS:(NSString*)hnAlgDS;
+(void) test2:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at ds:(NSString*)ds;
+(void) test3:(AIKVPointer*)pointer type:(AnalogyType)type ds:(NSString*)ds;
+(void) test4:(AIKVPointer*)pointer at:(NSString*)at isOut:(BOOL)isOut;
+(void) test5:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at;
+(void) test6:(NSArray*)types;
+(void) test7:(NSArray*)arr type:(AnalogyType)type;
+(void) test8:(NSArray*)content_ps type:(AnalogyType)type;
+(void) test9:(AIFoNodeBase*)fo type:(AnalogyType)type;
+(void) test10:(TOModelBase*)toModel;
+(void) test11:(AIShortMatchModel*)shortModel waitAlg_p:(AIKVPointer*)waitAlg_p;

/**
 *  MARK:--------------------判断一个评分是否异常--------------------
 */
+(void) test12:(CGFloat)score;

+(void) test13:(NSArray*)slowSolutionCansets;

+(void) test14:(CGFloat)near;

@end
