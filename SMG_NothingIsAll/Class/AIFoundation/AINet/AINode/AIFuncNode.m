//
//  AIFuncNode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFuncNode.h"
#import "AINetStore.h"
#import "AISingleNode.h"

@implementation AIFuncNode

+(AIFuncNode*) newWithFuncPointer:(AIKVPointer*)funcPointer singleNodePointer:(AIKVPointer*)singleNodePointer{
    AIFuncNode *funcNode = [[AIFuncNode alloc] init];
    funcNode.funcPointer = funcPointer;
    funcNode.singleNodePointer = singleNodePointer;
    return funcNode;
}

-(void) setContent:(id)content{
        //2. 反射子神经元
        //a. 取神经元算法数据
        AIFuncModel *funcModel = self.content;
        if (ISOK(funcModel, AIFuncModel.class)) {
            //b. 执行算法
            
            
            //c. 存算法值
            //...此处需要取到另一个存储结果的神经元节点;而Func节点;必定关联了两个(1. 多功能节点; 2. 存算法结果Data节点);
            //...两种解决方式;1. 分写几个AINode的子类; 2. 将AIPort分成四部分(传入,传出,存入,关联); 3. 保持现状,丰富type,使用判断type的方式解决;
            //d. 传递到new DataNode();
        }
}

-(void)run:(NSArray *)args{
    if (ISOK(self.funcPointer, AIKVPointer.class)) {
        AIFuncModel *model = [[AINetStore sharedInstance] objectForKvPointer:self.funcPointer];
        if (ISOK(model, AIFuncModel.class)) {
            //2. 执行
            id value =[model run:args];
            
            //3. 输出至singleNode
            if (ISOK(self.singleNodePointer, AIKVPointer.class)) {
                AISingleNode *singleNode = [[AINetStore sharedInstance] objectForKvPointer:self.singleNodePointer];
                if (ISOK(singleNode, AISingleNode.class)) {
                    [singleNode run:@[value]];
                }
            }
            
            
        }
    }else{
        NSLog(@"ERROR!!!_____(FuncModel Invalid)");
    }
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.funcPointer = [aDecoder decodeObjectForKey:@"funcPointer"];
        self.singleNodePointer = [aDecoder decodeObjectForKey:@"singleNodePointer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.funcPointer forKey:@"funcPointer"];
    [aCoder encodeObject:self.singleNodePointer forKey:@"singleNodePointer"];
}


@end
