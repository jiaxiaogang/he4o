//
//  DemoHunger.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/14.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------Mind元:饥饿--------------------
 */
@interface DemoHunger : NSObject

-(void) commit:(CGFloat)level state:(UIDeviceBatteryState)state;

@end

