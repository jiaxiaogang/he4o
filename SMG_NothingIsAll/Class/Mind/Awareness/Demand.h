//
//  Demand.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------需求--------------------
 *  意识组织产生需求,决定当前去做什么(参考:AI/框架/Mind/Demand & AI/框架/Understand/Awareness->Demand->ThinkTask任务 & N3P11)
 */
@interface Demand : NSObject

-(void) runAnalyze:(NSInteger)count;
-(void) stop;//打断

@end
