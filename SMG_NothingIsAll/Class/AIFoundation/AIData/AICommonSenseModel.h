//
//  AICommonSenseModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------常识表--------------------
 *  AIAwareness的升层;(参考N3P5)
 *  1,是什么(属性)(苹果的颜色是绿色)
 *  2,能做什么(接口)(苹果能吃)
 *  3,
 *  注:以AIObj表等"知识图谱表"为基础使用;
 *  注:通过类比,来教给AI什么是颜色;然后通过"强化"来使AI确定颜色的概念;(颜色算法函数,的反射的AIPointer,与取颜色的任务关联)
 */
@interface AICommonSenseModel : NSObject

@end
