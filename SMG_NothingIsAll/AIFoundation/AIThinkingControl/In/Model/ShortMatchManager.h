//
//  ShortMatchManager.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------(短时记忆) 瞬时识别数据管理器--------------------
 *  1. 存最多4条;
 *  @desc 每一桢输入TIR,都会进行识别,并生成一个AIShortMatchModel实例;
 *  @version
 *      2020.08.17: 将瞬时记忆整合到短时记忆中来;
 *  @todo TODO_NEXT_VERSION: 与ShortMemory进行整合 (完成);
 */
@class AIShortMatchModel;
@interface ShortMatchManager : NSObject

-(NSMutableArray*)models;
-(void) add:(AIShortMatchModel*)model;

/**
 *  MARK:--------------------获取某帧index的模型--------------------
 *  @status 废弃状态 (如果2023.10之前未用,则删除);
 */
-(AIShortMatchModel*) getFrameModel:(NSInteger)frameIndex;

/**
 *  MARK:--------------------获取瞬时记忆序列--------------------
 *  @result 返回AIShortMatchModel_Simple数组 notnull;
 */
-(NSMutableArray*) shortCache:(BOOL)isMatch;

-(void) clear;

@end
