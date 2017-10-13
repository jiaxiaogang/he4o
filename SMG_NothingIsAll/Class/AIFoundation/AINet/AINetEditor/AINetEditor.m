//
//  AINetEditor.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINetEditor.h"
#import "NENode.h"
#import "NEFuncNode.h"
#import "NEMultiNode.h"
#import "AINet.h"

#define StringAlgs @"StringAlgs"

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
    
    //1. editorNode
    NEFuncNode *eFuncNode = [NEFuncNode newWithEId:1 funcModel:nil funcClass:NSClassFromString(StringAlgs) funcSel:NSSelectorFromString(@"length:")];
    [self.elements addObject:eFuncNode];
    
    //2. 添加NEMutilNode;
    NEMultiNode *multiNodeElement = [NEMultiNode newWithEId:2 args:eFuncNode,nil];
    [self.elements addObject:multiNodeElement];
    
    //3. 调用mutilNode
    //4. 根据数据结果生成DataNode;
    
}

-(void) refreshNet{
    //存
    for (NEElement *element in self.elements) {
        [element refreshNet];
    }
    
    //AINet对接Input功能区
    for (NEElement *element in self.elements) {
        if (element.eId == 2) {
            [theNet addStringNode:element.nodePointer];
        }
    }
}


@end







