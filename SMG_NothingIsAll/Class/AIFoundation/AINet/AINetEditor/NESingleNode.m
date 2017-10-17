//
//  NESingleNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/10/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NESingleNode.h"
#import "AINetStore.h"
#import "AISingleNode.h"

@implementation NESingleNode


-(void) refreshNet{
    if (![[AINetStore sharedInstance] containsNodeWithEId:self.eId]) {
        //1. 存node
        AISingleNode *node = [[AISingleNode alloc] init];
        BOOL success = [[AINetStore sharedInstance] setObjectWithNetNode:node];
        
        //2. 建立node.pointer & eId映射
        if (success) {
            [[AINetStore sharedInstance] setMapWithNodePointer:node.pointer withEId:self.eId];
        }
    }
}


@end
