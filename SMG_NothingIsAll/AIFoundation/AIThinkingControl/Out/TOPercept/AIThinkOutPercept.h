//
//  AIThinkOut.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DemandModel,TOFoModel,AIShortMatchModel,ReasonDemandModel;
@protocol AIThinkOutPerceptDelegate <NSObject>

//提交C给TOR行为化;
-(void) aiTOP_2TOR_PerceptSub:(TOFoModel*)outModel;
-(BOOL) aiTOP_2TOR_PerceptPlus:(AIFoNodeBase *)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo;

@end

//MARK:===============================================================
//MARK:                     < dataOut (回归具象之旅) >
//MARK: 简述:
//MARK:     1. 向性: 左下;
//MARK:     2. 功能: TOP负责将需求mv转成可实现的fo;
//MARK:     3. 模型: TOP是左下的递归循环, (对最优先的任务,做mv方向索引最强的解决方案,并逐一提交到TOR尝试行为化);
//MARK:
//MARK: 说明: 在helix内核的决策中,helix经历了5个关键节点;
//MARK:     1. mv需求(input或其它状态触发)
//MARK:     2. mv经验查找(从网络索引找)
//MARK:     3. 经验模型(从网络关联找)
//MARK:     4. 执行方案(从网络具体经历单位找(时序等))
//MARK:     5. 正式输出(这里会用到小脑,helix未实现小脑网络);
//MARK: 总结: 这整个过程算是helix的具象之旅,也是output循环的几个关键节点
//MARK:     1. 在TOFoModel之前,找出多个方案进行实时刷新pk,来评价目前想执行哪个;
//MARK:     2. 而到TOFoModel之后,找出1个方案逐个尝试,失败则不应期,成功则输出;
//MARK:     3. 所有方法,递归总方法; (参考n16p5)
//MARK:     4. score的取值,取各具象层次第一名 (即最好学校的最好班级的最好学生) (参考n16p5)
//MARK:
//MARK:===============================================================
@interface AIThinkOutPercept : NSObject

@property (weak, nonatomic) id<AIThinkOutPerceptDelegate> delegate;

/**
 *  MARK:--------------------fromTO主入口--------------------
 */
-(BOOL) perceptSub:(DemandModel*)demandModel;
-(BOOL) perceptPlus:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel;

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 */
+(void) top_OPushM:(AICMVNodeBase*)newMv;

@end


/**
 *  MARK:--------------------日志--------------------
 *  20190215:去掉tryout执行 >> 对某标识ds&at的数据输出的激活功能; (已由吸吮反射等反射方式替代);
 */
