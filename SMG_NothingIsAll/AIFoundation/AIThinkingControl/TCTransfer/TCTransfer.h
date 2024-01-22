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

/**
 *  MARK:--------------------canset迁移算法 (29069-todo10)--------------------
 */
+(void) transfer:(TOFoModel*)bestCansetModel complate:(void(^)(AITransferModel *brother,AITransferModel *father,AITransferModel *i))complate;

/**
 *  MARK:--------------------伪迁移 (仅得出模型) (参考31073-TODO1)--------------------
 */
+(void) transferForModel:(TOFoModel*)rCansetModel;

//取继承model: 传fatherCanset节点版本
+(TCJiCenModel*) transferJiCenForModel:(AIFoNodeBase*)fatherCanset fatherCansetTargetIndex:(NSInteger)fatherCansetTargetIndex fatherScene:(AIFoNodeBase*)fatherScene iScene:(AIFoNodeBase*)iScene;

//取继承model: 传fatherCanset的内容版本
+(TCJiCenModel*) transferJiCenForModel:(NSArray*)fatherCansetContent_ps fatherCansetDeltaTimes:(NSArray*)fatherCansetDeltaTimes fatherSceneCansetIndexDic:(NSDictionary*)fatherSceneCansetIndexDic fatherCansetTargetIndex:(NSInteger)fatherCansetTargetIndex fatherScene:(AIFoNodeBase*)fatherScene iScene:(AIFoNodeBase*)iScene;

//取推举model: 传brotherCanset节点版本
+(TCTuiJuModel*) transferTuiJuForModel:(AIFoNodeBase*)brotherCanset brotherCansetTargetIndex:(NSInteger)brotherCansetTargetIndex brotherScene:(AIFoNodeBase*)brotherScene fatherScene:(AIFoNodeBase*)fatherScene;

/**
 *  MARK:--------------------cansetAlg迁移算法 (29075-方案3)--------------------
 */
+(AIKVPointer*) transferAlg:(AISceneModel*)sceneModel canset:(AIFoNodeBase*)canset cansetIndex:(NSInteger)cansetIndex;

@end
