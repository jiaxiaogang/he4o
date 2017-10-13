//
//  AIMultiNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMultiNode.h"
#import "AINetStore.h"

@implementation AIMultiNode

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.nodes = [[NSMutableArray alloc] init];
}

/**
 *  MARK:--------------------取出--------------------
 *  返回子节点组;
 *  contentPointer是指针数组的指针;
 *  content是指针数据;其中每个元素都是一个节点指针;
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


/**
 *  MARK:--------------------run--------------------
 */
-(void) run:(NSArray*)args{
    //1. 将参数传递给子节点
    for (AIKVPointer *pointer in self.nodes) {
        AINode *node = [[AINetStore sharedInstance] objectForKvPointer:pointer];
        if (ISOK(node, AINode.class)) {
            [node run:args];
        }
    }
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.nodes = [aDecoder decodeObjectForKey:@"nodes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.nodes forKey:@"nodes"];
}


@end
