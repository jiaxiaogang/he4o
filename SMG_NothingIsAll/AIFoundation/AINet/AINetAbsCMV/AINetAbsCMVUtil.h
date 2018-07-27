//
//  AINetAbsCMVUtil.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AICMVNode;
@interface AINetAbsCMVUtil : NSObject


/**
 *  MARK:--------------------取aNode和bNode的抽象urgentTo值--------------------
 */
+(NSInteger) getAbsUrgentTo:(AICMVNode*)aMv bMv_p:(AICMVNode*)bMv;


/**
 *  MARK:--------------------取aNode和bNode的抽象delta值--------------------
 */
+(NSInteger) getAbsDelta:(AICMVNode*)aMv bMv_p:(AICMVNode*)bMv;


@end
