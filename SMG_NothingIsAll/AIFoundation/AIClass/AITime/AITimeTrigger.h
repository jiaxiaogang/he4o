//
//  AITime.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------生物钟触发器--------------------
 *  @version
 *      2020.08.14: 支持生物钟触发器;
 *          1. timer计时器触发,取deltaT x 1.3时间;
 *          2. 将预想时序fo,和实际时序fo存至触发器中;
 *          3. 当outModel中某时序完成时,则追回(销毁)与其对应的触发器;
 *          4. 直到触发时,还未销毁,则说明实际时序并未完成,此时调用反省类比;
 *      2020.08.23: 改为由TOFoModel中setTimeTrigger方法替代;
 */
@class TOModelBase;
@interface AITimeTrigger : NSObject

//@property (assign, nonatomic) NSTimeInterval time;          //AI运行的时间
//@property (assign,nonatomic) NSTimeInterval *awarenessTime; //意识时间
//
//@property (strong, nonatomic) AIFoNodeBase *actionFo;       //预想fo
//@property (strong, nonatomic) AIFoNodeBase *realFo;         //实际fo

/**
 *  MARK:--------------------生物钟触发器--------------------
 */
+(void) setTimeTrigger:(NSTimeInterval)deltaTime canTrigger:(BOOL(^)())canTrigger trigger:(void(^)())trigger;

@end
