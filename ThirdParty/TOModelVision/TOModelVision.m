//
//  TOModelVision.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOModelVision.h"
#import "TOModelBase.h"

@implementation TOModelVision

+(NSString*) cur2Root:(TOModelBase*)curModel{
    //1. 数据准备
    NSMutableString *mStr = [[NSMutableString alloc] init];
    TOModelBase *single = curModel;
    
    //2. 递归取值
    while (single) {
        NSString *singleStr = [self singleVision:single];
        
        //3. 当前/base有效时,插入首部一行;
        if (STRISOK(singleStr)) {
            if (STRISOK(mStr)) [mStr insertString:@"\n   ↑\n" atIndex:0];
            [mStr insertString:singleStr atIndex:0];
        }
        single = single.baseOrGroup;
    }
    
    //4. 头尾
    [mStr insertString:@"\n===========================\n" atIndex:0];
    [mStr appendString:@"\n==========================="];
    return mStr;
}

+(NSString*) singleVision:(TOModelBase*)model{
    if (model) {
        return STRFORMAT(@"%@: %@",NSStringFromClass(model.class),Pit2FStr(model.content_p));
    }
    return nil;
}

@end
