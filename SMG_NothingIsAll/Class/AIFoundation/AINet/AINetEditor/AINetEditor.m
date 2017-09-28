//
//  AINetEditor.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINetEditor.h"
#import "AINetEditor_Node.h"
#import "AINetEditor_FuncModel.h"

@implementation AINetEditor

+(void) updateNet{

    //1. funcModel
    AIFuncModel *funcModel = [[AIFuncModel alloc] init];
    AINetEditor_FuncModel *eFuncModel = [[AINetEditor_FuncModel alloc] init];//
    
    //2. 存funcModel;
    
    //3. funcNode
    AIFuncNode *funcNode = [AIFuncNode newWithFuncModelPointer:funcModel.pointer];
    
    //4. editorNode
    AINetEditor_Node *eNode = [AINetEditor_Node newWithNode:funcNode eId:@"1"];
    
    
}



@end







