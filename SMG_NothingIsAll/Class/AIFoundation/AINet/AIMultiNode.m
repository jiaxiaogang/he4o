//
//  AIMultiNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMultiNode.h"

@implementation AIMultiNode

/**
 *  MARK:--------------------取出--------------------
 *  返回子节点组;
 */
-(id) content{
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    if (POINTERISOK(self.contentPointer)) {
        //1. 取子节点组指针数组
        NSArray *nodePointers = [[NSMutableArray alloc] initWithArray:self.contentPointer.content];//(此处最好直接用指针指向某个代码数组)//xxx
        //2. 遍历当前节点
        for (AIPointer *pointer in ARRTOOK(nodePointers)) {
            //3. 收集子节点
            AINode *node = pointer.content;
            if (ISOK(node, AINode.class)) {
                [nodes addObject:node];
            }
        }
        
    }
    return nodes;
}

/**
 *  MARK:--------------------传入--------------------
 */
-(void) setContent:(id)content{
    NSMutableArray *nodes = [self content];
    //功能型神经元将数据下发到子神经元
    for (AINode *node in ARRTOOK(nodes)) {
        if (ISOK(node, AINode.class)) {
            [node setContent:content];
        }
    }
}



@end
