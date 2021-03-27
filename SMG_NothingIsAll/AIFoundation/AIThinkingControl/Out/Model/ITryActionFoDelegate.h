//
//  ITryActionFoDelegate.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/28.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------fo解决方案接口--------------------
 *  @version
 *      2020.05.28: 用于R-,P-,GL,Hav四处时序构建子outModel模型;
 */
@protocol ITryActionFoDelegate <NSObject>

-(NSMutableArray*) actionFoModels;

@end
