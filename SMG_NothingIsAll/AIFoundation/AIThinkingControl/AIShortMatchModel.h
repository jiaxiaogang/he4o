//
//  ActiveCache.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理性的,瞬时匹配模型--------------------
 *  说明: AIShortMatchModel是TOR理性思维的model结果;
 *  @desc 191104 : 将activeCache更名为shortMatch,并传递给TOR使用;
 *  @desc 模型说明:
 *      1. 供TOR使用的模型一共有三种: 瞬时,短时,长时;
 *      2. 瞬时由模型承载,而短时和长时由Net承载;
 *      3. 此AIShortMatchModel是瞬时的模型;
 */
@interface AIShortMatchModel : NSObject

@property (strong, nonatomic) AIKVPointer *protoAlg_p;  //原始概念
@property (strong, nonatomic) AIAlgNodeBase *matchAlg;  //匹配概念
@property (strong, nonatomic) AIFoNodeBase *protoFo;    //原始时序
@property (strong, nonatomic) AIFoNodeBase *matchFo;    //匹配时序
@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度

@property (strong, nonatomic) AICMVNodeBase *useNode;   //旧有useNode,估计会删掉;

@end
