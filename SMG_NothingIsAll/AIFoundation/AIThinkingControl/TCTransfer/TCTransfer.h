//
//  TCTransfer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------迁移器--------------------
 *  @desc 负责Canset的迁移功能 (参考29069-todo10.1 & todo10.2 & 688示图);
 *  @desc 目前仅R任务支持迁移器,H任务暂未支持;
 */
@interface TCTransfer : NSObject

//MARK:===============================================================
//MARK:                     < 一用一体迁移算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------伪迁移 (仅得出模型) (参考31073-TODO1)--------------------
 */
+(void) transferForModel:(TOFoModel*)cansetModel;

/**
 *  MARK:--------------------迁移之体 (仅构建节点和初始spDic) (参考31073-TODO2c)--------------------
 */
+(void) transferForCreate:(TOFoModel*)cansetModel;

//MARK:===============================================================
//MARK:                     < 一虚一实V2 >
//MARK:===============================================================

+(void) transferXv:(TOFoModel*)cansetModel;
+(void) transferSi:(TOFoModel*)cansetModel;

//MARK:===============================================================
//MARK:                     < 概念迁移算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------cansetAlg迁移算法 (29075-方案3)--------------------
 */
+(AIKVPointer*) transferAlg:(AISceneModel*)sceneModel canset:(AIFoNodeBase*)canset cansetIndex:(NSInteger)cansetIndex;

@end
