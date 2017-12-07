//
//  AIThinkingRule.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 思维 >
//MARK:===============================================================
@interface AIThinkingRule : NSObject

-(void) activityByShallow:(id)data;  //潜
-(void) activityByDeep:(id)data;     //主
//-(void) activityByNone:(id)data;   //无(无在Thinking内即可创建,无需主观激活)

@end
