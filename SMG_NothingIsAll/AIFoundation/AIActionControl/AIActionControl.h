//
//  AIActionControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIImvAlgsModel;
@interface AIActionControl : NSObject


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
+(AIActionControl*) shareInstance;
-(void) commitInput:(id)input;
-(void) commitCustom:(CustomInputType)type value:(NSInteger)value;

@end
