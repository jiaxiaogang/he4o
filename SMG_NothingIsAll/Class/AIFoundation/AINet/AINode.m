//
//  AINode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

@implementation AINode

-(id) content{
    return nil;
}

-(void) setContent:(id)content{
    if (self.type == AINodeType_Data) {
        
    }else if (self.type == AINodeType_Func) {
        
    }else if (self.type == AINodeType_MultiFunc) {
        
    }else{
        NSLog(@"AINodeType Is ERROR!!!");
    }
}


@end
