//
//  AINode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------节点--------------------
 *  
 *  每个节点包括一个指针,指向数据本体,一个AIPort指向其连接的AILine;
 */
@class AIKVPointer;
@interface AINode : AIObject

@property (assign, nonatomic) AINodeDataType dataType;
@property (strong,nonatomic) NSMutableArray *ports;     //item为AILine.pointer
@property (strong,nonatomic) AIKVPointer *dataPointer;  //数据指针

//MARK:===============================================================
//MARK:                     < 内容传入传出 >
//MARK:===============================================================
-(id) content;
-(void) setContent:(id)content;

@end
