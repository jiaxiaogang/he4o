//
//  AISolutionModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单条S候选集与proto对比结果模型--------------------
 */
@interface AISolutionModel : NSObject

+(AISolutionModel*) newWithCansetFo:(AIKVPointer*)cansetFo protoFo:(AIKVPointer*)protoFo matchValue:(CGFloat)matchValue cutIndex:(NSInteger)cutIndex;

@property (strong, nonatomic) AIKVPointer *cansetFo;
@property (strong, nonatomic) AIKVPointer *protoFo;
@property (assign, nonatomic) CGFloat matchValue;   //前段(已发生部分)匹配度 (相近度和/已发生数);
@property (assign, nonatomic) CGFloat stableScore;  //后段稳定性分 (用于慢思考);
@property (assign, nonatomic) CGFloat effectScore;  //整体有效率分 (用于快思考);
@property (assign, nonatomic) NSInteger cutIndex;   //已发生截点 (含cutIndex也已发生);

@end
