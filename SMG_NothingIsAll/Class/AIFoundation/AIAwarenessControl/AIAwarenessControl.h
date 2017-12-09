//
//  AIAwarenessControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------意识控制器--------------------
 *  只作觉醒判断,真正的意识控制器由"思维控制器"接管;
 */
@interface AIAwarenessControl : NSObject

+(AIAwarenessControl*) shareInstance;
-(id) init;
-(void) awake;
-(void) sleep;
/**
 *  MARK:--------------------入口--------------------
 */
-(void) commitInput:(id)data;

@end
