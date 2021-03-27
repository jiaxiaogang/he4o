//
//  ISubModelsDelegate.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/28.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------子元素接口--------------------
 *  @desc 比如时序FoOutModel下的元素即是概念AlgOutModel;
 */
@protocol ISubModelsDelegate <NSObject>

/**
 *  MARK:--------------------subModels--------------------
 *  1. 在TOFoModel时,subModels为其content_ps中的概念们;
 *  2. 在TOAlgModel时,subModels为其SP方法中保留的稀疏码对比GLDic的subValues 和 尝试整体Hav的那些subAlgs;
 */
-(NSMutableArray*) subModels;

@end
