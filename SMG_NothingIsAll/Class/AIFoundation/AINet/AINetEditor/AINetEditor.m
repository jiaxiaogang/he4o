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
    NEFuncNode *eFuncNode = [NEFuncNode newWithEId:1 funcModel:nil funcClass:NSClassFromString(@"NSString") funcSel:NSSelectorFromString(@"length")];
    [self.elements addObject:eFuncNode];
    
    
}

-(void) refreshNet{
    for (NEElement *element in self.elements) {
        [element refreshNet];
    }
}

@end







