//
//  SMG.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Store.h"
#import "GC.h"
#import "MindHeader.h"

@interface SMG : NSObject

@property (strong,nonatomic) Store *store;  //记忆功能;
@property (strong,nonatomic) GC *gc;        //回收器

/**
 *  MARK:--------------------问话--------------------
 */
-(void) requestWithText:(NSString*)test withComplete:(void (^)(NSString* response))complete;

/**
 *  MARK:--------------------收到回复--------------------
 */
-(void) responseWithJoyAngerType:(JoyAngerType)joyAngerType ;
@end
