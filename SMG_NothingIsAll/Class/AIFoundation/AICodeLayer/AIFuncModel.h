//
//  AIFuncModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------Function算法函数等"反射节点"模型--------------------
 */
@interface AIFuncModel : AIObject

@property (assign, nonatomic) Class funcClass;
@property (assign, nonatomic) SEL funcSel;

@end





















//@property (strong,nonatomic) NSString *className;
//@property (strong,nonatomic) NSString *methodName;
