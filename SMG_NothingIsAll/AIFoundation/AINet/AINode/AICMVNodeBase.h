//
//  AICMVNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeBase.h"

/**
 *  MARK:--------------------价值节点基类--------------------
 *  1. 有指针地址;
 *  2. 有迫切度;
 *  3. 有变化;
 *  TODO: 可考虑将cmv的抽具象去掉;
 *  @version
 *      2023.03.11: 价值节点也是概念的一种 (参考28171-todo7);
 *      2023.08.10: 把foNode改成数组ports (参考30095-todo2);
 */
@interface AICMVNodeBase : AIAlgNodeBase

@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
@property (strong, nonatomic) NSMutableArray *foPorts;  //前因数据

@end
