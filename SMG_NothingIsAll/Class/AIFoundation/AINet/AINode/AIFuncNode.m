//
//  AIFuncNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFuncNode.h"
#import "AINetStore.h"


@implementation AIFuncNode

+(AIFuncNode*) newWithFuncModel:(AIFuncModel*)funcModel{
    AIFuncNode *funcNode = [[AIFuncNode alloc] init];
    funcNode.funcModel = funcModel;
    return funcNode;
}

-(id) content{
    if (self.funcModel) {
        return self.funcModel;
    }else if (POINTERISOK(self.contentPointer)) {
        //1. 取节点指针
        AIFuncModel *funcModel = self.contentPointer.content;
        return funcModel;
    }
    return nil;
}

-(void) setContent:(id)content{
        //2. 反射子神经元
        //a. 取神经元算法数据
        AIFuncModel *funcModel = self.content;
        if (ISOK(funcModel, AIFuncModel.class)) {
            //b. 执行算法
            id value = [funcModel invoke:content,nil];
            //c. 存算法值
            //...此处需要取到另一个存储结果的神经元节点;而Func节点;必定关联了两个(1. 多功能节点; 2. 存算法结果Data节点);
            //...两种解决方式;1. 分写几个AINode的子类; 2. 将AIPort分成四部分(传入,传出,存入,关联); 3. 保持现状,丰富type,使用判断type的方式解决;
            //d. 传递到new DataNode();
        }
}

-(void)run:(NSArray *)args{
    if (ISOK(self.funcModel, AIFuncModel.class)) {
        [self.funcModel run:args];
    }else{
        NSLog(@"ERROR!!!_____(FuncModel Invalid)");
    }
}

@end
