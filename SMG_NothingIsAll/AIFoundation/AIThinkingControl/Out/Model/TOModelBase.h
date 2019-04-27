//
//  TOModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOModelBase : NSObject

-(id) initWithContent_p:(AIPointer*)content_p;

@property (strong, nonatomic) AIPointer *content_p;
@property (assign, nonatomic) CGFloat score;            //评分
@property (strong, nonatomic) NSMutableArray *except_ps;//不应期
@property (strong, nonatomic) NSMutableArray *subModels;//具象子集序列 (实时有序)

-(TOModelBase*) getCurSubModel;
-(BOOL) isEqual:(TOModelBase*)object;

/**
 *  MARK:--------------------每层第一名之和分值--------------------
 *  获取综合第一名,需要由下至上;
 */
-(CGFloat) allNiceScore;

@end
