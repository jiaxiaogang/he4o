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
@class AIShortMatchModel,TOModelBase,TOAlgModel,TOFoModel;
@protocol TOActionDelegate <NSObject>

-(void) toAction_Output:(NSArray*)actions;
-(AIShortMatchModel*) toAction_RethinkInnerFo:(AIFoNodeBase*)fo;
-(void) toAction_SubModelFinish:(TOModelBase*)outModel;
-(void) toAction_SubModelActYes:(TOModelBase*)outModel;
-(void) toAction_SubModelFailure:(TOModelBase*)outModel;
-(void) toAction_SubModelBegin:(TOModelBase*)outModel;
-(void) toAction_ReasonScorePM:(TOAlgModel*)outModel failure:(void(^)())failure notNeedPM:(void(^)())notNeedPM;

@end

/**
 *  MARK:--------------------行为化类--------------------
 *  ********旧版*******
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
 *
 *  ********新版********
 *  @version 20200520由TOAlgScheme大改版而来;
 *  @desc
 *      1. 支持两个主要入口方法:
 *          a. SP
 *          b. P
 *      2. 支持子时序递归 (当cHav时,转移至另一时序);
 *      3. 支持outModel:
 *          a. 行为化成功时,cutIndex右移至下帧;
 *          b. 转移时,将subOutModel存至outModel;
 *      4. 两种工作模式: (参考19185)
 *          a. 第一种为默认工作模式: 为每支循环都进行直接行为输出外循环 (当前默认即为此种);
 *          b. 第二种为辅助工作模式: 即默认不足时,进行辅助,先进行规划,即预行为化其下所有分支,再依次输出行为 (暂不支持,待v2三测后再考虑支持);
 *      5. 负责所有TOModel.status的变化,且status赋值时,调用流程控制方法 (调用者只管调用触发,模型生成,参数保留);
 *  @todo
 *      1. 评价支持: 将fo返回到subOutModel并进行score评价);
 *      2. 短时记忆支持:在转移时,生成subOutModel并放到outModel下;
 */
@class TOAlgModel,TOValueModel;
@interface AIThinkOutAction : NSObject

@property (weak, nonatomic) id<TOActionDelegate> delegate;

//用于R-四模式调用;
-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p outModel:(TOAlgModel*)outModel;

//用于Fo.Begin时调用;
-(void) convert2Out_Fo:(TOFoModel*)outModel;

//用于Alg.Begin时调用;
-(void) convert2Out_Hav:(TOAlgModel*)outModel;

//用于Value.Begin时调用;
-(void) convert2Out_GL:(AIAlgNodeBase*)alg outModel:(TOValueModel*)outModel;

@end
