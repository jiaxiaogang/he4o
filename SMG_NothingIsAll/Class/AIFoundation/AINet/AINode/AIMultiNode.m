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
