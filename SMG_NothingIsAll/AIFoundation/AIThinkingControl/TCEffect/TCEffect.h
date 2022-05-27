//
//  TCEffect.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/22.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------记录Demand的解决方案有效率--------------------
 *  @desc 对新的解决方案有效性的反省 (参考26094 & 26095);
 *      1. 构建Demand任务时调用;
 *      2. 有效性倒计时触发;
 *      3. 根据demand.status状态判断有效性;
 *      4. 将有效性,计入任务源fos的effectDic中;
 */
@interface TCEffect : NSObject

+(void) rEffect:(TOFoModel*)rSolution;
+(void) hEffect:(TOFoModel*)hSolution;

@end
