//
//  AINetAbsCMVUtil.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINetAbsCMVUtil : NSObject


/**
 *  MARK:--------------------取aNode和bNode的抽象urgentTo值--------------------
 */
+(NSInteger) getAbsUrgentTo:(NSArray*)mvNodes;


/**
 *  MARK:--------------------取aNode和bNode的抽象delta值--------------------
 */
+(NSInteger) getAbsDelta:(NSArray*)mvNodes;

/**
 *  MARK:--------------------获取抽象mv的初始方向索引强度--------------------
 *  @version:
 *      最初版 - 报告添加direction引用 (difStrong暂时先x2;(因为一般是两个相抽象))
 *      20200425前 - 使用absMv的urgentTo做初始强度;
 *      20200425后 - 使用具象中最强的方向索引强度+1 (参考n19p13);
 */
+(NSInteger) getDefaultStrong_Index:(AIAbsCMVNode*)absMv conMvs:(NSArray*)conMvs;

@end
