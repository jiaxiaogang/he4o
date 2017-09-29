//
//  NEFuncNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEFuncNode.h"

@interface NEFuncNode ()

@property (strong,nonatomic) NSString *eId;
@property (strong,nonatomic) AIPointer *funcModelPointer;
@property (assign, nonatomic) Class funcClass;
@property (assign, nonatomic) SEL funcSel;

@end

@implementation NEFuncNode



+(id) newWithEId:(NSString*)eId funcModelPointer:(AIPointer*)funcModelPointer funcClass:(Class)funcClass funcSel:(SEL)funcSel{
    NEFuncNode *value = [[NEFuncNode alloc] init];
    value.eId = eId;
    value.funcModelPointer = funcModelPointer;
    value.funcClass = funcClass;
    value.funcSel = funcSel;
    return value;
}


-(void) refreshNet{
    if (POINTERISOK(self.funcModelPointer)) {
        //1. node
        AIFuncNode *node = [AIFuncNode newWithFuncModelPointer:self.funcModelPointer];
        
        //2. 存node并建立id和node.pointer映射
        
        
        
    }else if(self.class != nil && self.funcSel != nil){
        //1. model
        AIFuncModel *model = [[AIFuncModel alloc] init];
        
        //2. node
        AIFuncNode *node = [AIFuncNode newWithFuncModelPointer:model.pointer];
        
        //3. 存node并建立id和node.pointer映射
        
        
    }else{
        NSLog(@"ERROR!!!_____(NEFuncNode Invalid)");
    }
    
    
    
}

@end
