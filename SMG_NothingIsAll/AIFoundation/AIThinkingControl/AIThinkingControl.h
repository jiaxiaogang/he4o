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


/**
 *  MARK:--------------------流入input--------------------
 */
-(void) commitInput:(NSObject*)algsModel;


/**
 *  MARK:--------------------输出的日志入网(输入小脑)--------------------
 *  @param algsType  : 输出算法分区(目前仅有Output)
 *  @param dataSource    : 输出算法函数(如output_Text:)
 *  @param outputObj : 输出内容(如:饿死爹了)
 */
-(void) commitOutputLog:(NSString*)algsType dataSource:(NSString*)dataSource outputObj:(NSNumber*)outputObj;

@end
