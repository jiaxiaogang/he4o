//
//  AIDataNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIDataNode.h"

@implementation AIDataNode


-(id) content{
    if (POINTERISOK(self.contentPointer)) {
        return self.contentPointer.content;
    }
    return nil;
}

-(void) setContent:(id)content{
    //1. 生成pointer地址;
    //2. 存content
    //3. 存本节点;
}



@end
