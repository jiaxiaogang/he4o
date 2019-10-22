//
//  AIThinkOut.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DemandModel,TOFoModel;
@protocol AIThinkOutPerceptDelegate <NSObject>

-(DemandModel*) aiThinkOutPercept_GetCurrentDemand;         //获取当前需求;
-(BOOL) aiThinkOutPercept_EnergyValid;                      //能量值是否>0;
-(void) aiThinkOutPercept_UpdateEnergy:(CGFloat)delta;      //更新思维能量值;
-(void) aiThinkOutPercept_Commit2TOR:(TOFoModel*)foModel;   //提交foModel给TOR做理性行为化
-(void) aiThinkOutPercept_MVSchemeFailure;                  //找解决mv经历失败

@end

//MARK:===============================================================
//MARK:                     < dataOut (回归具象之旅) >
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
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *  4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考;
 *  5. 从expCache下,根据可行性,选定一个解决方案;
 *  6. 有需求时,找出outMvModel,尝试决策并解决;
 *
 *  框架: index -> mvNode -> foNode -> algNode -> action
 *  注:
 *  1. return           : 决策思维中止;
 *  2. [self dataOut]   : 递归再跑
 *
 */
-(void) dataOut;


@end


/**
 *  MARK:--------------------日志--------------------
 *  20190215:去掉tryout执行 >> 对某标识ds&at的数据输出的激活功能; (已由吸吮反射等反射方式替代);
 */
