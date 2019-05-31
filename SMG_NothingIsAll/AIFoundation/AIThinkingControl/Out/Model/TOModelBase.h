//
//  TOModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------ThinkOut模型--------------------
 *  1. 优中选优策略,即当前仅可找到得分第一位的,进行决策;
 *  2. 不可跳层进行score计算; 95%采用
 *  3. 可跳层进行综合计算; 5%采用
 */
@interface TOModelBase : NSObject

-(id) initWithContent_p:(AIPointer*)content_p;

@property (strong, nonatomic) AIPointer *content_p;

/**
 *  MARK:--------------------score排序因子--------------------
 *  1. order是实时变化的,(如,因为懒而order-,导致某任务决定放弃)
 *  2. 懒运算,
 *  注: 后续添加对时间衰减的支持
 */
@property (assign, nonatomic) CGFloat score;            //评分
@property (strong, nonatomic) NSMutableArray *except_ps;//不应期
@property (strong, nonatomic) NSMutableArray *subModels;//具象子集序列 (实时有序)


/**
 *  MARK:--------------------获取当前最强的outSubModel--------------------
 *  @result 返回TOModelBase或其子类型;
 */
-(id) getCurSubModel;

/**
 *  MARK:--------------------对比是否相等--------------------
 */
-(BOOL) isEqual:(TOModelBase*)object;

/**
 *  MARK:--------------------每层第一名之和分值--------------------
 *  获取综合第一名,需要由下至上;
 */
-(CGFloat) allNiceScore;

@end
