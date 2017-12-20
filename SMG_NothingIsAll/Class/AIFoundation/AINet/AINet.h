//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel;
@interface AINet : NSObject

+(AINet*) sharedInstance;

//MARK:===============================================================
//MARK:                     < 事务对接区(AIObject内感) >
//MARK:===============================================================
-(void) commitString:(NSString*)str;
-(void) commitInput:(id)input;
-(void) commitProperty:(id)data rootPointer:(AIPointer*)rootPointer;
-(void) commitModel:(AIModel*)model;

@end
