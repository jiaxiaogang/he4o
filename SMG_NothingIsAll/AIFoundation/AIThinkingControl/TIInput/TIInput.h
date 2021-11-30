//
//  TIInput.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIInput : NSObject

+(void) rInput:(AIAlgNodeBase*)algNode fromGroup_ps:(NSArray*)fromGroup_ps;
+(void) pInput:(NSArray*)algsArr;
+(void) jump:(TOAlgModel*)algModel;

@end
