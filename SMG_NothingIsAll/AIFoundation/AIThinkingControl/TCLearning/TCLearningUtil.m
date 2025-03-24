//
//  TCLearningUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/24.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "TCLearningUtil.h"

@implementation TCLearningUtil

/**
 *  MARK:--------------------乘积匹配度中的单码对整体的责任占比（整体责任为1，个体责任为0-1）--------------------
 *  @result true无责 false有责
 */
+(BOOL) noZeRenForCenJi:(CGFloat)curMatchValue bigerMatchValue:(CGFloat)bigerMatchValue {
    //31. 二者相似度较高时 (计算当前码的责任比例: 比如:1*0.8*0.7时,当前码=0.7时,它的责任比例=(1-0.7)/(1-0.8 + 1-0.7)=60%) (参考29025-13);
    CGFloat otherValueMatchValue = curMatchValue > 0 ? bigerMatchValue / curMatchValue : 1;   //别的码相乘是0.xx;
    CGFloat otherQueKou = 1 - otherValueMatchValue;                                             //别的码缺口;
    CGFloat curQueKou = 1 - curMatchValue;                                                    //当前码缺口;
    CGFloat sumQueKou = otherQueKou + curQueKou;                                                //总缺口;
    CGFloat curRate = sumQueKou > 0 ? curQueKou / sumQueKou : 0;                                //算出当前码责任比例;
    //if (Log4Ana) NSLog(@"> 当前<%@>比<%@>的缺口",Pit2FStr(protoV_p),Pit2FStr(assV_p));
    return curRate < 0.5;
}


/**
 *  MARK:--------------------平均匹配度中的单码责任占比（个体责任 > 平均责任 x 2则突显其有责任）--------------------
 *  @result true无责 false有责
 */
+(BOOL) noZeRenForPingJun:(CGFloat)curMatchValue bigerMatchValue:(CGFloat)bigerMatchValue {
    CGFloat bigerZeRen = 1 - bigerMatchValue;//整体的责任
    CGFloat subZeRen = 1 - curMatchValue;//个体的责任。
    return subZeRen < bigerZeRen * 2;
}

@end
