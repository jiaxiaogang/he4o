//
//  NEFuncNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NEFuncNode.h"
#import "AINetStore.h"
#import "NESingleNode.h"

@interface NEFuncNode ()

@property (strong,nonatomic) AIFuncModel *funcModel;
@property (assign, nonatomic) Class funcClass;
@property (assign, nonatomic) SEL funcSel;
@property (strong,nonatomic) NESingleNode *singleNode;  //输出

@end

@implementation NEFuncNode

+(id) newWithEId:(NSInteger)eId funcModel:(AIFuncModel*)funcModel funcClass:(Class)funcClass funcSel:(SEL)funcSel singleNode:(NESingleNode*)singleNode{
    NEFuncNode *value = [[NEFuncNode alloc] init];
    value.eId = eId;
    value.funcModel = funcModel;
    value.funcClass = funcClass;
    value.funcSel = funcSel;
    value.singleNode = singleNode;
    return value;
}

-(void) refreshNet{
    //1. 根据element参数创建model
    AIFuncModel *model = nil;
    if (ISOK(self.funcModel, AIFuncModel.class)) {
        model = self.funcModel;
    }else if(self.funcClass != nil && self.funcSel != nil){
        model = [[AIFuncModel alloc] init];
        model.funcClass = self.funcClass;
        model.funcSel = self.funcSel;
    }
    
    //2. 更新神经网络
    if (model && self.singleNode) {
        //3. 存FuncModel;
        if (![[AINetStore sharedInstance] containsFuncModelWithEId:self.eId]) {
            BOOL success = [[AINetStore sharedInstance] setObjectWithFuncModel:model];
            //4. 存funcModel & eId映射
            if (success) {
                [[AINetStore sharedInstance] setMapWithFuncModelPointer:model.pointer withEId:self.eId];//element的data指向会继用父eId;
            }
        }
        
        //4. 取singleNodePointer
        AIKVPointer *singleNodePointer = [self.singleNode nodePointer];
        
        //5. 存node节点
        if (![[AINetStore sharedInstance] containsNodeWithEId:self.eId]) {
            AIFuncNode *node = [AIFuncNode newWithFuncPointer:model.pointer singleNodePointer:singleNodePointer];
            BOOL success = [[AINetStore sharedInstance] setObjectWithNetNode:node];
            
            //6. 建立node.pointer & eId映射
            if (success) {
                [[AINetStore sharedInstance] setMapWithNodePointer:node.pointer withEId:self.eId];
            }
        }
    }else{
        NSLog(@"ERROR!!!_____(NEFuncNode Invalid)");
    }
}


@end
