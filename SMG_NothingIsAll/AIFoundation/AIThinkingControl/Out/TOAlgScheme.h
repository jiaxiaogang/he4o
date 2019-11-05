//
//  TOAlgScheme.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------TO中,对于概念的判定部分--------------------
 *  作用: 以时序与概念的协作,来做理性判定;
 *  TODO1: 随后对TOAlgScheme添加energy消耗,以精确控制;
 *  TODO2: 根据havAlg构建成ThinkOutAlgModel (暂时不需要)
 *  TODO3: 将DemandModel->TOMvModel->TOFoModel->TOAlgModel->TOActionModel的模型结构化关系整理清晰; (前三个已用,后两个暂不需要)
 *  BUG记录: (参考:n17p14)
 *      Q: 190725,outMvModel取到解决问题的mvDirection结果,但再往下仍进到反射输出,查为什么行为化失败了;
 *      A: 190820-191022: 由此处行为化失败率太高,而引出必须细化TR`理性思维`;
 *      A: 191104: 行为化失败率太高,可能仅是因为内类比构建时未去重,导致无法索引到
 *      R: 191104: 但也因此而细化了理性思维,也细化了瞬时记忆对理性的支持
 */
@class AIShortMatchModel;
@interface TOAlgScheme : NSObject

/**
 *  MARK:--------------------setData--------------------
 *  @param shortMatchModel : 传入瞬时匹配模型,以大大提高行为化成功率;
 */
-(void)setData:(AIShortMatchModel *)shortMatchModel;

/**
 *  MARK:--------------------多个概念rangeOrder行为化;--------------------
 *  代码步骤: (发现->距离->飞行)
 *  1. 比如找到坚果,由有无时序来解决"有无"问题; (cNone,cHav) (有无)
 *  2. 找到的坚果与fo中进行类比;(找出坚果距离的不同,或者坚果带皮儿的不同) (cLess,cGreater) (变化)
 *  3. 将距离与带皮转化成行为,条件的行为化; (如飞行,或去皮); (actionScheme) (行为)
 */
-(NSArray*) convert2Out:(NSArray*)curAlg_ps;


@end
