//
//  TCRethinkUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/20.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCRethinkUtil.h"

@implementation TCRethinkUtil

/**
 *  MARK:--------------------抽象也更新SPEFF (参考29069-todo11.4 & todo11.5)--------------------
 *  @param curFo : 当前正在SPEFF的fo (本方法就是取它的抽象);
 *  @param curFoIndex : 当前正在对fo的此下标下的帧执行更新SPEFF;
 */
+(void) spEff4Abs:(AIFoNodeBase*)curFo curFoIndex:(NSInteger)curFoIndex itemRunBlock:(void(^)(AIFoNodeBase *absFo,NSInteger absIndex))itemRunBlock {
    //1. 数据准备;
    NSArray *absPorts = [AINetUtils absPorts_All:curFo];
    for (AIPort *absPort in absPorts) {
        //2. P: mv是目标帧的: 直接执行;
        if (curFoIndex == curFo.count) {
            AIFoNodeBase *absFo = [SMGUtils searchNode:absPort.target_p];
            itemRunBlock(absFo,absFo.count);
        }
        //3. R: 理性目标帧时: 判断indexDic映射到目标帧再执行;
        else {
            NSDictionary *indexDic = [curFo getAbsIndexDic:absPort.target_p];
            NSNumber *absIndex = ARR_INDEX([indexDic allKeysForObject:@(curFoIndex)], 0);
            if (absIndex) {
                //4. 目标帧映射有效 => 执行;
                AIFoNodeBase *absFo = [SMGUtils searchNode:absPort.target_p];
                itemRunBlock(absFo,absIndex.integerValue);
            }
        }
    }
}

@end
