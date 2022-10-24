//
//  AIAlgNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------概念节点基类--------------------
 *  1. TODO: 将概念添加isOut,或将foNode.orders中添加每个元素的isOut;
 *  2. TODOv2.0: 将refPorts独立成文件;
 *  3. 概念嵌套: 目前不进行概念嵌套,因太复杂,而由抽具象或组分关联来替代; (组分关联即嵌套?参考嵌套相关文档再决定)
 *  @todo
 *      2021.03.24: 将OutRT反省构建的SP节点,从absPorts中迁至此处,独立定义为ports;
 */
@interface AIAlgNodeBase : AINodeBase

@property (strong, nonatomic) NSMutableArray *refPorts; //引用序列
@property (strong, nonatomic) NSMutableDictionary *absMatchDic; //抽象匹配度字典 <K:对方pId, V:相似度> (参考27153-todo2);
@property (strong, nonatomic) NSMutableDictionary *conMatchDic; //具象匹配度字典 <K:对方pId, V:相似度> (参考27153-todo2);

/**
 *  MARK:--------------------更新抽具象相似度--------------------
 *  @param absAlg : 传抽象节点进来,而self为具象节点;
 */
-(void) updateMatchValue:(AIAlgNodeBase*)absAlg matchValue:(CGFloat)matchValue;

@end
