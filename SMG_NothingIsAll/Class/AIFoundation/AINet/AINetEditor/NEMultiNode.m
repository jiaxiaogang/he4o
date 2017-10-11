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

-(void) refreshNet{
    //1. 取子节点的kvPointer
    if (ARRISOK(self.arr)) {
        for (NEElement *element in self.arr) {
            if (ISOK(element, NEElement.class)) {
                [element refreshNet];
            }
        }
    }
    
    //2. 存自身
    
    AIMultiNode *node = [AIMultiNode newWithContent:nil];
    
    //2. 更新神经网络
    if (model) {
        //3. 存FuncModel;
        if (![[AINetStore sharedInstance] containsFuncModelWithEId:self.eId]) {
            BOOL success = [[AINetStore sharedInstance] setObjectWithFuncModel:model];
            //4. 存funcModel & eId映射
            if (success) {
                [[AINetStore sharedInstance] setMapWithFuncModelPointer:model.pointer withEId:self.eId];
            }
        }
        
        //5. 存node节点
        if (![[AINetStore sharedInstance] containsNodeWithEId:self.eId]) {
            AIFuncNode *node = [AIFuncNode newWithFuncModel:model];
            BOOL success = [[AINetStore sharedInstance] setObjectWithNetNode:node];
            
            //6. 建立node.pointer & eId映射
            if (success) {
                [[AINetStore sharedInstance] setMapWithNodePointer:node.pointer withEId:self.eId];
            }
        }
    }else{
        NSLog(@"ERROR!!!_____(NEFuncNode Invalid)");
    }
}

@end
