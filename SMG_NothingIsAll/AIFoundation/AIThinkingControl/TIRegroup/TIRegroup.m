//
//  TIRegroup.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIRegroup.h"

@implementation TIRegroup

+(void) rRegroup:(AIShortMatchModel*)model{
    //1. 构建时序 (把每次dic输入,都作为一个新的内存时序);
    NSArray *matchAShortMem = [theTC.inModelManager shortCache:true];
    model.matchAFo = [theNet createConFo:matchAShortMem isMem:false];
    NSArray *protoAShortMem = [theTC.inModelManager shortCache:false];
    model.protoFo = [theNet createConFo:protoAShortMem isMem:false];
    
    //2. 识别
    [TIRecognition rRecognition:model];
}

+(void) pRegroup{
    
}

+(void) hRegroup{
    
}

@end
