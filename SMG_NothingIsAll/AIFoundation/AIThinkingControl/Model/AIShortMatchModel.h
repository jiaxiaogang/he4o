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
 *  @todo
 *      1. 支持多条matchAlg,多条matchFo,将fuzzys独立列出;
 *      2. 在多条matchFo.mv价值预测下,可以相应的跑多个正向反馈类比,和反向反馈类比;
 */
@interface AIShortMatchModel : NSObject

//MARK:===============================================================
//MARK:                     < Alg部分 >
//MARK:===============================================================
@property (strong, nonatomic) AIAlgNodeBase *protoAlg;  //原始概念
@property (strong, nonatomic) AIAlgNodeBase *matchAlg;  //匹配概念
@property (assign, nonatomic) MatchType algMatchType;   //概念匹配类型


//MARK:===============================================================
//MARK:                     < Fo部分 >
//MARK:===============================================================
/**
 *  MARK:--------------------原始时序--------------------
 *  @desc
 *      1. 不可轻易改为由protoAlg构建,因为matchAlg对红色或距离的认识才是几个标志性值(比如5,8,13,21,57);
 *          a. 内类比成果因此而,这对以后决策时进行匹配有用,如果改成protoAlg构建,这个值会非常多,使决策循环也非常多才能找到有用的经验;
 *          b. 反向反馈类比成果也同理,对MC中MC是否有效可行为化的判定非常有用,因为一旦无法MC匹配到mIsC,那么将进入下轮决策循环;
 *  @version
 *      2020.06.26: 将protoFo拆分为protoFo和matchAFo两部分;
 */
@property (strong, nonatomic) AIFoNodeBase *protoFo;

/**
 *  MARK:--------------------由matchAlg构建的时序--------------------
 *  @desc
 *      1. 将原先protoFo,拆分为:protoFo和matchAFo两部分实现;
 *      2. 由前几桢瞬时中的matchAlg来构建;
 */
@property (strong, nonatomic) AIFoNodeBase *matchAFo;

@property (strong, nonatomic) AIFoNodeBase *matchFo;    //匹配时序
@property (assign, nonatomic) CGFloat matchFoValue;     //时序匹配度
@property (assign, nonatomic) NSInteger cutIndex;       //已发生与预测的截点 (0开始,已发生含cutIndex);

@end
