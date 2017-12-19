//
//  AINetEditor.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINetEditor.h"
#import "NENode.h"
#import "NEDataNode.h"
#import "NEMultiNode.h"
#import "NESingleNode.h"
#import "AINet.h"

@interface AINetEditor ()

@property (strong,nonatomic) NSMutableArray *elements;

@end

@implementation AINetEditor

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initNet];
    }
    return self;
}

-(void) initData{
    self.elements = [[NSMutableArray alloc] init];
}

-(void) initNet{
    //1. singleNode
    NESingleNode *singleNode = [[NESingleNode alloc] init];
    singleNode.eId = 1001;
    [self.elements addObject:singleNode];
}

-(void) refreshNet{
    //1. 存
    for (NEElement *element in self.elements) {
        [element refreshNet];
    }
    
    //2. 分配
    [self refreshAllotNodes];
}


/**
 *  MARK:--------------------AINet对接Input功能区--------------------
 */
-(void) refreshAllotNodes{
    for (NEElement *element in self.elements) {
        if (element.eId == 3001) {
            [theNet addStringNode:element.nodePointer];
        }
    }
}


@end







