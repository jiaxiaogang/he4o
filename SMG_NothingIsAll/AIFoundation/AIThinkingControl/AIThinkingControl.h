//
//  AIThinkingControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 思维 >
//MARK:===============================================================
@interface AIThinkingControl : NSObject

+(AIThinkingControl*) shareInstance;
-(void) inputByShallow:(NSObject*)data;  //潜

@end
