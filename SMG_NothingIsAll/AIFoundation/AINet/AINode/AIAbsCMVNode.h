//
//  AIAbsCMVNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------AIAbsCMVNode--------------------
 *  1. 今后可考虑将conPorts拆分,(注意,外界不需要知道有这样的拆分)(封装个毛,麻烦)
 */
@interface AIAbsCMVNode : AICMVNodeBase

@property (strong, nonatomic) NSMutableArray *conPorts; //具象方向端口;


/**
 *  MARK:--------------------添加具象关联--------------------
 *  注:从大到小(5,4,3,2,1)
 */
-(void) addConPorts:(AIPort*)conPort;


-(AIPort*) getConPort:(NSInteger)index;


/**
 *  MARK:--------------------获取conPort--------------------
 *  @param except_ps : 要排除的pointer数组;
 */
-(AIPort*) getConPortWithExcept:(NSArray*)except_ps;

@end
