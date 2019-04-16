//
//  TOAlgModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------决策中的祖母模型--------------------
 *  1. 将content_p中的祖母进行行为化;
 */
@interface TOAlgModel : NSObject

@property (strong, nonatomic) AIPointer *content_p;//AIAlgNodeBase_p
@property (strong, nonatomic) NSMutableArray *except_ps;//排除序列

@end
