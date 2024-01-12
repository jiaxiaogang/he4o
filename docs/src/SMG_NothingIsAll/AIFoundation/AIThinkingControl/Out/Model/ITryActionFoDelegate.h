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
 *  @implement
 *      1. DemandModel  : 用于挂载R和P任务的解决方案;
 *      2. TOAlgModel   : 用于挂载HN解决方案;
 *      3. TOValueModel : 用于挂载GL解决方案;
 *  @version
 *      2020.05.28: 用于R-,P-,GL,Hav四处时序构建子outModel模型;
 *      2021.03.27: 支持反思子任务 (当outFoModel实现此接口时,下方为子任务) (参考22193);
 */
@protocol ITryActionFoDelegate <NSObject>

-(NSMutableArray*) actionFoModels;

@end
