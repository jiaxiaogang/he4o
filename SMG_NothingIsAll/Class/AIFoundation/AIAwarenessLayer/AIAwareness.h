//
//  AIAwareness.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < 意识器 >
//MARK:===============================================================
@interface AIAwareness : NSObject

+(AIAwareness*) shareInstance;
-(id) init;
-(void) awake;
-(void) sleep;
/**
 *  MARK:--------------------入口--------------------
 */
-(void) commitInput:(id)data;

@end
