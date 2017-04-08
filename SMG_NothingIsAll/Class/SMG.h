//
//  SMG.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindHeader.h"


@class Language,GC,Store;
@interface SMG : NSObject

+(id) sharedInstance;
@property (strong,nonatomic) Store *store;          //记忆功能;
@property (strong,nonatomic) GC *gc;                //回收器
@property (strong,nonatomic) Language *language;    //语言输入输出能力
@property (strong,nonatomic) Mind *mind;            //当前心情



/**
 *  MARK:--------------------问话--------------------
 */
-(void) requestWithText:(NSString*)text withComplete:(void (^)(NSString* response))complete;



/**
 *  MARK:--------------------收到回复--------------------
 */
-(void) requestWithJoyAngerType:(JoyAngerType)joyAngerType ;


@end
