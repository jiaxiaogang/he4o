//
//  AIThinkOutAction.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/5/20.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------行为化代理--------------------
 */
@class AIShortMatchModel,TOModelBase;
@protocol TOActionDelegate <NSObject>

-(void) toAction_updateEnergy:(CGFloat)delta;
-(BOOL) toAction_EnergyValid;
-(void) toAction_Output:(NSArray*)actions;
-(AIShortMatchModel*) toAction_RethinkInnerFo:(AIFoNodeBase*)fo;
-(void) toAction_SubModelFinish:(TOModelBase*)outModel;
-(void) toAction_SubModelFailure:(TOModelBase*)outModel;

//TODOTOMORROW:
//1. 整理所有status的变化,一切调用者只管调用触发,还有模型生成,参数保留;
//2. 一切流程控制的转移,失败递归,成功推进,都由流程控制方法完成;
//3. 流程控制方法,由_Hav,_GL这些具体方法来调用;

@end

/**
 *  MARK:--------------------行为化类--------------------
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
 *  @todo
 *      1. 评价支持: 将fo返回到subOutModel并进行score评价);
 *      2. 短时记忆支持:在转移时,生成subOutModel并放到outModel下;
 */
@class TOAlgModel,TOValueModel;
@interface AIThinkOutAction : NSObject

@property (weak, nonatomic) id<TOActionDelegate> delegate;

//用于TO四模式调用;
-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p outModel:(TOAlgModel*)outModel;
-(void) convert2Out_P:(TOAlgModel*)outModel;

//用于转移时调用;
-(void) convert2Out_Hav:(TOAlgModel*)outModel;
-(void) convert2Out_GL:(AIAlgNodeBase*)alg outModel:(TOValueModel*)outModel;

@end
