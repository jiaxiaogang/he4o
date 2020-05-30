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
-(void) toAction_Output:(NSArray*)actions;

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
 *  @todo
 *      1. 评价支持: 将fo返回到subOutModel并进行score评价);
 *      2. 短时记忆支持:在转移时,生成subOutModel并放到outModel下;
 */
@class TOAlgModel;
@interface AIThinkOutAction : NSObject

@property (weak, nonatomic) id<TOActionDelegate> delegate;

-(void) convert2Out_SP:(AIKVPointer*)sAlg_p pAlg_p:(AIKVPointer*)pAlg_p outModel:(TOAlgModel*)outModel;
-(void) convert2Out_P:(TOAlgModel*)outModel;

@end
