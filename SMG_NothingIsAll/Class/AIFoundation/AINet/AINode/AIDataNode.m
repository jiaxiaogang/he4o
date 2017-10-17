//
//  AIDataNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIDataNode.h"
#import "AINetStore.h"

@implementation AIDataNode


-(id) content{
    if (POINTERISOK(self.contentPointer)) {
        return self.contentPointer.content;
    }
    return nil;
}

-(NSMutableArray *)ports{
    if (_ports == nil) {
        _ports = [[NSMutableArray alloc] init];
    }
    return _ports;
}

-(void)run:(NSArray *)args{
    if (ARRISOK(args)) {
        AIObject *obj = [args firstObject];
        if (ISOK(obj, AIObject.class)) {
            //1. 存data
            [[AINetStore sharedInstance] setObjectWithNetData:obj];
            self.dataPointer = obj.pointer;
            
            //2. 存本节点;
            [[AINetStore sharedInstance] setObjectWithNetNode:self];
        }else{
            NSLog(@"AIDataNodeRunIsERROR!!!___(dataIsInValid)");
        }
    }
}


@end
