//
//  RLTrainer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGrowPage @"GrowPage"
#define kFly @"Fly"
#define kWood @"Wood"

@interface RLTrainer : NSObject

+(RLTrainer*) sharedInstance;

-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector;
-(void) queue1:(NSString*)name;
-(void) queue1:(NSString*)name count:(NSInteger)count;
-(void) queueN:(NSArray*)names count:(NSInteger)count;

@end
