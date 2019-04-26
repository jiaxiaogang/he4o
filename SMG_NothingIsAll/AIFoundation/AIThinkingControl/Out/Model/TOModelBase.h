//
//  TOModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOModelBase : NSObject

@property (strong, nonatomic) AIKVPointer *content_p;
@property (assign, nonatomic) CGFloat score;            //评分
@property (strong, nonatomic) NSMutableArray *except_ps;//不应期
@property (strong, nonatomic) NSMutableArray *subModels;//具象子集序列 (实时有序)

-(TOModelBase*) getCurSubModel;

@end
