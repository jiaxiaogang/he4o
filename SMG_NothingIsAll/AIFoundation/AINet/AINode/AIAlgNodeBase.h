//
//  AIAlgNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

@interface AIAlgNodeBase : AINodeBase

@property (strong, nonatomic) NSMutableArray *absPorts;
@property (strong, nonatomic) NSMutableArray *refPorts; //引用序列
@property (strong, nonatomic) NSArray *value_ps;        //微信息组 (以pointer默认排序)

@end
