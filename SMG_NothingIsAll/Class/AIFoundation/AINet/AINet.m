//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "CodeLayerHeader.h"

@interface AINet ()

@property (strong,nonatomic) NSMutableArray *stringNodes;

@end

@implementation AINet

//MARK:===============================================================
//MARK:                     < String反射区 >
//MARK:===============================================================
-(void) commitString:(NSString*)str{
    
    //2, 调用反射算法处理并返回值给神经网络;
    
    
    if (STRISOK(str)) {
        //1. 必调字符串算法;
        
        //TEST临时写成AIFuncModel;其实应该取的是节点;并且节点是完全AIPointer取到才对;
        for (AIFuncModel *model in self.stringNodes) {
            [model run:str];
        }
        
        
    }
    
}



/**
 *  MARK:--------------------get--------------------
 */
-(NSMutableArray *)stringNodes{
    if (_stringNodes == nil) {
        _stringNodes = [[NSMutableArray alloc] init];
        
        
        NSMutableArray *algs = [StringAlgs algs];
        
        //AINet add
        
        [_stringNodes addObjectsFromArray:algs];
    }
    return _stringNodes;
}

@end
