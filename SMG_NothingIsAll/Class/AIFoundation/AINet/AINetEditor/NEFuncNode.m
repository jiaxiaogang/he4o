//
//  NEFuncNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEFuncNode.h"
#import "AINetStore.h"





@interface NEFuncNode ()

@property (strong,nonatomic) AIFuncModel *funcModel;
@property (assign, nonatomic) Class funcClass;
@property (assign, nonatomic) SEL funcSel;

@end

@implementation NEFuncNode



+(id) newWithEId:(NSInteger)eId funcModel:(AIFuncModel*)funcModel funcClass:(Class)funcClass funcSel:(SEL)funcSel{
    NEFuncNode *value = [[NEFuncNode alloc] init];
    value.eId = eId;
    value.funcModel = funcModel;
    value.funcClass = funcClass;
    value.funcSel = funcSel;
    return value;
}


-(void) refreshNet{
    if (ISOK(self.funcModel, AIFuncModel.class)) {
        //1. node
        AIFuncNode *node = [AIFuncNode newWithFuncModel:self.funcModel];
        //2. 存node并建立id和node.pointer映射
        
        
        
    }else if(self.funcClass != nil && self.funcSel != nil){
        //1. model
        AIFuncModel *model = [[AIFuncModel alloc] init];
        model.funcClass = self.funcClass;
        model.funcSel = self.funcSel;
        
        //2. 存FuncModel;
        BOOL success = [[AINetStore sharedInstance] setObjectWithFuncModel:model];
        
        //3. 存funcModel & eId映射
        if (success) {
            [[AINetStore sharedInstance] setMapWithFuncModelPointer:model.pointer withEId:self.eId];
        }
        
        //4. node
        AIFuncNode *node = [AIFuncNode newWithFuncModel:model];
        
        //5. 存node
        success = [[AINetStore sharedInstance] setObjectWithNetNode:node];
        
        //6. 建立node.pointer & eId映射
        if (success) {
            [[AINetStore sharedInstance] setMapWithNodePointer:node.pointer withEId:self.eId];
        }
    }else{
        NSLog(@"ERROR!!!_____(NEFuncNode Invalid)");
    }
    
    
    
}

/**
 *  MARK:--------------------run--------------------
 */
-(void) run{
    if (ISOK(self.funcModel, AIFuncModel.class)) {
        [self.funcModel run:nil];
    }else if(self.funcClass != nil && self.funcSel != nil){
        //1. model
        AIFuncModel *model = [[AIFuncModel alloc] init];
        model.funcClass = self.funcClass;
        model.funcSel = self.funcSel;
        [model run:nil];
    }else{
        NSLog(@"ERROR!!!_____(FuncModel Invalid)");
    }
}


@end
