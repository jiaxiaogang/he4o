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
 *  @desc
 *      1. 集成原则: 在方法被调用前,将outModel实例化好,并当参数传递进去,在方法执行中status变化的,重新对status赋值即可;
 */
@interface TOModelBase : NSObject

-(id) initWithContent_p:(AIKVPointer*)content_p;

@property (strong, nonatomic) AIKVPointer *content_p;
@property (weak, nonatomic) TOModelBase *baseOrGroup;

/**
 *  MARK:--------------------score排序因子--------------------
 *  1. order是实时变化的,(如,因为懒而order-,导致某任务决定放弃)
 *  2. 懒运算,
 *  注: 后续添加对时间衰减的支持
 */
//@property (assign, nonatomic) CGFloat score;            //评分
@property (strong, nonatomic) NSMutableArray *except_ps;//下级不应期收集

/**
 *  MARK:--------------------对比是否相等--------------------
 */
-(BOOL) isEqual:(TOModelBase*)object;

/**
 *  MARK:--------------------当前model的状态--------------------
 */
@property (assign, nonatomic) TOModelStatus status;

@end
