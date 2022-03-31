//
//  RLTrainer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGrowPage @"GrowPage"

@interface RLTrainer : NSObject

+(RLTrainer*) sharedInstance;

-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector;
-(void) invoke:(NSString*)name;

@end
