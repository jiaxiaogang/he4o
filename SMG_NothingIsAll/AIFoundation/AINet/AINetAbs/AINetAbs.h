//
//  AINetAbs.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < AINetAbs管理器 >
//MARK:===============================================================
@class AINetAbsNode;
@interface AINetAbs : NSObject


/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @params foNodes : 具象节点
 *  @params refs_p : 微信息组
 */
-(AINetAbsNode*) create:(NSArray*)foNodes refs_p:(NSArray*)refs_p;

@end
