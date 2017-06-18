//
//  Mine.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hunger.h"

@protocol MineDelegate <NSObject>

-(void) mine_HungerStateChanged:(HungerStatus)status;

@end


/**
 *  MARK:--------------------mind元:"精神自我"--------------------
 *  1,主观体验:(我怎么知道自己在思考;(感觉"自我");)
 *      • 例如:感觉"自我":主观意识的计时,和生物钟的计时,很明显不是一样的;
 *      • 两个层级:
 *          基于代码的计算;(无log,无意识思维)
 *          基于数据的计算;(有数据log,有意识思维)
 *  注:(参考:OneNote/AI/框架/我)(随后专门开发这个功能)
 *
 *  //待开发:
 *      1,gps位置,
 *      2,时间,
 *      3,感知经历了充电,
 *      4,感知经历了思考数据,
 *      5,对沟通和了解外界有永久好奇心;(nlp阶段这么搞)
 *      6,很容易产生无聊感;(产生主动"表述"行为)
 */
@class Mood,Hobby;
@interface Mine : NSObject

@property (weak, nonatomic) id<MineDelegate> delegate;
@property (strong,nonatomic) Hunger *hunger;
@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) Hobby *hobby;

/**
 *  MARK:--------------------获取当前最迫切的自我需求数据--------------------
 */
-(MindStrategyModel*) getMindStrategyModelForDemand;

@end
