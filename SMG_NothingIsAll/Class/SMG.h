//
//  SMG.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindHeader.h"


@class GC,Store,Understand,Feel,Input;
@interface SMG : NSObject

+(SMG*) sharedInstance;
@property (strong,nonatomic) Store *store;          //记忆功能;
@property (strong,nonatomic) GC *gc;                //回收器
@property (strong,nonatomic) Mind *mind;            //当前心情
@property (strong,nonatomic) Understand *understand;//闲下时,开始理解分析自己的记忆和知识;
@property (strong,nonatomic) Feel *feel;            //感觉系统
@property (strong,nonatomic) Input *input;          //输入系统(计算机视觉,听觉,文字,触觉,网络等)


/**
 *  MARK:--------------------method--------------------
 */

//MARK:--------------------QA--------------------
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete;//问话
-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType ;//收到回复



@end

