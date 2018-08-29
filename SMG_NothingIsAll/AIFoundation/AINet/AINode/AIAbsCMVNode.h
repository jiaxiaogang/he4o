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
 *  1. 今后可考虑将conPorts拆分,(注意封装,外界不需要知道有这样的拆分)
 */
@interface AIAbsCMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身地址
@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
//@property (strong, nonatomic) NSMutableArray *conPorts; //具象方向端口;
@property (strong, nonatomic) AIKVPointer *absNode_p;   //前因节点


/**
 *  MARK:--------------------添加具象关联--------------------
 *  注:从大到小(5,4,3,2,1)
 */
-(void) addConPorts:(AIPort*)conPort;


-(AIPort*) getConPort:(NSInteger)index;


@end
