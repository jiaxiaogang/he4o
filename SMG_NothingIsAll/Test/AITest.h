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

@end
