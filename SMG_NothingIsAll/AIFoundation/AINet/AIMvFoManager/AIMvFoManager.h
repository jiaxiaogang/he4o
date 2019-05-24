//
//  AIMvFoManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
/**
 *  MARK:--------------------foNode->cmvNode的模型--------------------
 */
@interface AIMvFoManager : NSObject

/**
 *  MARK:--------------------create foNode->cmvNode 基本模型--------------------
 *  @param imvAlgsArr : imv此次输入信息
 *  @param order : 瞬时记忆序列
 *  @result : 返回foNode;
 */
-(AIFrontOrderNode*) create:(NSArray*)imvAlgsArr order:(NSArray*)order;

@end
