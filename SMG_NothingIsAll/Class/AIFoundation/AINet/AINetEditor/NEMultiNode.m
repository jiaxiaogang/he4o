//
//  NEMultiNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEMultiNode.h"
#import "AINetStore.h"

@interface NEMultiNode ()

@property (strong,nonatomic) NSMutableArray *arr;

@end

@implementation NEMultiNode

+(id) newWithEId:(NSInteger)eId args:(NEElement*)arg,...{
    SMGArrayMake(arg);
    NEMultiNode *value = [[NEMultiNode alloc] init];
    value.eId = eId;
    value.arr = array;
    return value;
}

-(void) refreshNet {
    AIMultiNode *multiNode = [[AIMultiNode alloc] init];
    
    //1. 取子节点的kvPointer
    if (ARRISOK(self.arr)) {
        for (NEElement *element in self.arr) {
            if (ISOK(element, NEElement.class)) {
                [element refreshNet];//存子element
                AIKVPointer *nodePointer = [element nodePointer];//收集nodePointer
                [multiNode.nodes addObject:nodePointer];
            }
        }
    }
    
    //2. 存自身
    BOOL success = [[AINetStore sharedInstance] setObjectWithNetNode:multiNode];
    //4. 存multiNode & eId映射
    if (success) {
        [[AINetStore sharedInstance] setMapWithNodePointer:multiNode.pointer withEId:self.eId];
    }else{
        NSLog(@"ERROR!!!_____(NEFuncNode Invalid)");
    }
}

@end
