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
@protocol TOActionDelegate <NSObject>

-(void) toAction_updateEnergy:(CGFloat)delta;
-(BOOL) toAction_EnergyValid;

@end

/**
 *  MARK:--------------------行为化类--------------------
 *  @version 20200520由TOAlgScheme大改版而来;
 *  @desc
 *      1. 支持两个主要入口方法:
 *          a. SP_Value
 *          b. P_Alg
 *      2. 支持子时序递归 (当cHav时,转移至另一时序);
 *      3. 支持outModel:
 *          a. 行为化成功时,cutIndex右移至下帧;
 *          b. 转移时,将subOutModel存至outModel;
 */
@interface AIThinkOutAction : NSObject

@property (weak, nonatomic) id<TOActionDelegate> delegate;

-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p complete:(void(^)(BOOL success,NSArray *acts))complete;
-(void) convert2Out_SP_Hav:(AIKVPointer*)curAlg_p complete:(void(^)(BOOL itemSuccess,NSArray *actions))complete checkScore:(BOOL(^)(AIAlgNodeBase *mAlg))checkScore;

@end
