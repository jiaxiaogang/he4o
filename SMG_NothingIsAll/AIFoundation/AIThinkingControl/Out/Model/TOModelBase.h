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
@interface TOModelBase : NSObject <NSCoding>

-(id) initWithContent_p:(AIKVPointer*)content_p;

@property (strong, nonatomic) AIKVPointer *content_p;

/**
 *  MARK:--------------------base--------------------
 *  @desc 因为决策短时记忆是结构化的,而baseOrGroup表示了其父节点;
 *  @callers
 *      1. TOFoModel时,base为: P满足/R避免/HNGL加工任务
 *      2. TOAlgModel时,base为: 时序
 *      3. TOValueModel时,base为: 概念
 *      4. DemandModel时,baes为: 产生子任务基于的哪个时序 (一般为反思时序);
 */
@property (weak, nonatomic) TOModelBase *baseOrGroup;

/**
 *  MARK:--------------------score排序因子--------------------
 *  1. order是实时变化的,(如,因为懒而order-,导致某任务决定放弃)
 *  2. 懒运算,
 *  注: 后续添加对时间衰减的支持
 */
//@property (assign, nonatomic) CGFloat score;            //评分

/**
 *  MARK:--------------------对比是否相等--------------------
 */
-(BOOL) isEqual:(TOModelBase*)object;

/**
 *  MARK:--------------------当前model的状态--------------------
 */
@property (assign, nonatomic) TOModelStatus status;

/**
 *  MARK:--------------------下级不应期收集--------------------
 *  @暂不需要: 目前用不着,因为直接从actionFoModels中取指针即可;
 */
//@property (strong, nonatomic) NSMutableArray *except_ps;

/**
 *  MARK:--------------------参数保留--------------------
 *  @desc 用于再决策: 当下层尝试失败时,会递归回来再决策,再决策时会用到这些参数,以调用行为化中的相应方法;
 *  @暂不开放: 目前用不着,再决策时,只需要传TOModel即可,而需要配合的mModel,也可以实时从短时记忆取;
 */
//@property (strong, nonatomic) NSDictionary *params;


/**
 *  MARK:--------------------来源标识--------------------
 *  @desc 初次实例化时的内存地址,此后序列化过,也保留此值 (参考25185-方案1);
 *  @version
 *      2022.03.23: 来源标识为: TOModel初次实例化时的内存地址 (参考25185-方案1-实践1);
 */
@property (strong, nonatomic) NSString *selfIden;

/**
 *  MARK:--------------------时间已等完--------------------
 *  @desc 因为现在TOStatus使用太泛太易变,所以独立此值
 *      1. 用处1. TOAlgModel用来表示alg是否在静默等待中间帧alg反馈;
 *      2. 用处2. TOFoModel用来表示fo是否在等待末帧mv反馈;
 */
@property (assign, nonatomic) BOOL actYesed;

@end
