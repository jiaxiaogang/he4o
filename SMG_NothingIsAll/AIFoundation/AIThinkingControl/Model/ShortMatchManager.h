//
//  ShortMatchManager.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------瞬时识别数据管理器--------------------
 *  1. 存最多4条;
 *  @desc 每一桢输入TIR,都会进行识别,并生成一个AIShortMatchModel实例;
 */
@class AIShortMatchModel;
@interface ShortMatchManager : NSObject

-(NSMutableArray*)models;
-(void) add:(AIShortMatchModel*)model;

@end

