//
//  SMG.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindHeader.h"


@class Language,GC,Store,Understand;
@interface SMG : NSObject

+(SMG*) sharedInstance;
@property (strong,nonatomic) Store *store;          //记忆功能;
@property (strong,nonatomic) GC *gc;                //回收器
@property (strong,nonatomic) Language *language;    //语言输入输出能力
@property (strong,nonatomic) Mind *mind;            //当前心情
@property (strong,nonatomic) Understand *understand;//闲下时,开始理解分析自己的记忆和知识;


/**
 *  MARK:--------------------method--------------------
 */

//MARK:--------------------QA--------------------
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete;//问话
-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType ;//收到回复



//MARK:--------------------Store--------------------
-(NSArray*) getStore_MemStore_MemArr;//获取习惯记忆;

@end
