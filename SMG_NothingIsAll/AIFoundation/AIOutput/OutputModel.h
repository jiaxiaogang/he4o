//
//  OutputModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/9.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出模型--------------------
 */
@interface OutputModel : NSObject

//通知标识符dataSource
@property (strong,nonatomic) NSString *rds;

//参数值 (目前仅支持1个) (应通过网络来实现组,而不是多参数)
@property (strong,nonatomic) NSNumber *data;

@end
