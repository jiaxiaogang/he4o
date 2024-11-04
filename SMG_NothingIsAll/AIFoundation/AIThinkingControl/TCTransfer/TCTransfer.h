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
 *  @version
 *      2023.04.19: 虚实整体版本 (参考29069);
 *      2024.01.19: 虚实分离(先虚,后由虚转实)版本 (参考31073);
 *      2024.02.29: 迭代H任务迁移 & 推举继承合并版本 (参考31113->31116);
 */
@interface TCTransfer : NSObject

//MARK:===============================================================
//MARK:                     < 经验迁移-虚实V3 >
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

//MARK:===============================================================
//MARK:                     < 推举算法V4 >
//MARK:===============================================================

/**
 *  MARK:--------------------在构建RCanset时,推举到抽象场景中 (参考33112)--------------------
 */
+(void) transferTuiJv_R:(AIFoNodeBase*)sceneFrom cansetFrom:(AIFoNodeBase*)cansetFrom;

/**
 *  MARK:--------------------在构建HCanset时,推举到抽象场景中 (参考33112)--------------------
 *  @param broRCansetActIndex 即broCanset正在行为化的帧 (它是新构建的hCanset的场景);
 */
+(void) transferTuiJv_H:(AIFoNodeBase*)broRScene broRCanset:(AIFoNodeBase*)broRCanset broRCansetActIndex:(NSInteger)broRCansetActIndex broHCanset:(AIFoNodeBase*)broHCanset;

@end
