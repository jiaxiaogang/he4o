//
//  TOAlgScheme.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------行为化代理--------------------
 */
@class AIShortMatchModel;
@protocol TOAlgSchemeDelegate <NSObject>

-(void) toAlgScheme_updateEnergy:(CGFloat)delta;
-(BOOL) toAlgScheme_EnergyValid;

//里氏反思
-(AIShortMatchModel*) toAlgScheme_LSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps;

@end

/**
 *  MARK:--------------------行为化--------------------
 *  作用: TO中,对于概念的判定部分 -> 以时序与概念的协作,来做理性判定;
 *  @desc 概念: 行为化,就是对当前现实世界所具备的"1资源"进行"2经验"有效利用,并输出"3行为",以达到"4目标";
 *  @desc 实例: 你有一个锤子,把眼前的坚果皮砸掉,并且吃掉坚果肉;
 *      1. 资源: 锤子,带皮坚果
 *      2. 经验: 吃坚果肉,带皮坚果可砸掉皮,坚果可以吃,吃可以解决饥饿问题等等
 *      3. 行为: 砸,吃
 *      4. 目标: 解决饥饿问题
 *  @desc 决策: 在行为化中,有正向递归循环的决策;
 *  @desc 反思:
 *      1. 在行为化中,以反向递归为评价,进行反思;
 *      2. 一个TR反思,包含多个CheckScore评价;
 *
 *  TODO1: 随后对TOAlgScheme添加energy消耗,以精确控制;
 *  TODO2: 根据havAlg构建成ThinkOutAlgModel (暂时不需要)
 *  TODO3: 将DemandModel->TOMvModel->TOFoModel->TOAlgModel->TOActionModel的模型结构化关系整理清晰; (前三个已用,后两个暂不需要)
 *  BUG记录: (参考:n17p14)
 *      Q: 190725,outMvModel取到解决问题的mvDirection结果,但再往下仍进到反射输出,查为什么行为化失败了;
 *      A: 190820-191022: 由此处行为化失败率太高,而引出必须细化TR`理性思维`;
 *      A: 191104: 行为化失败率太高,可能仅是因为内类比构建时未去重,导致无法索引到
 *      R: 191104: 但也因此而细化了理性思维,也细化了瞬时记忆对理性的支持
 *  迭代记录:
 *      1. 190419始: 初版,支持fo(),single_alg(),single_sub();在嵌套的支持下,支持单个alg和value的嵌套行为化;
 *      2. 191121完: 支持瞬时MC,增加行为化成功率; 参考:190行为化新架构图;
 *  简写与名词说明:
 *      1. CheckScore: CheckScore:表示评价;
 *      2. RT: Rethink:表示反思,因反思是递归的,故一次反思中,可能包含数轮递归并依次评价;
 */
@class AIShortMatchModel;
@interface TOAlgScheme : NSObject

@property (weak, nonatomic) id<TOAlgSchemeDelegate> delegate;

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
 *  @params curAlg_ps   : 当前需要行为化的部分ps;
 *  @param curFo        : 当前时序
 *  @param oldCheckScore: 反思路径记录,评价;
 */
-(void) convert2Out_Fo:(NSArray*)curAlg_ps curFo:(AIFoNodeBase*)curFo success:(void(^)(NSArray *acts))success failure:(void(^)())failure oldCheckScore:(BOOL(^)(AIAlgNodeBase *mAlg))oldCheckScore;


@end
