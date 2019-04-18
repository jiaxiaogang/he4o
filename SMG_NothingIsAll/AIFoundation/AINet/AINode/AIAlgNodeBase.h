//
//  AIAlgNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------祖母Base节点--------------------
 *  1. TODO: 将祖母添加isOut,或将foNode.orders中添加每个元素的isOut;
 *  2. TODOV1.1: 将refPorts独立成文件;
 */
@interface AIAlgNodeBase : AINodeBase

@property (strong, nonatomic) NSMutableArray *refPorts; //引用序列
@property (strong, nonatomic) NSArray *content_ps;      //(微信息/嵌套祖母)指针组 (以pointer默认排序)

@end
