//
//  AITransferPort_H.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/1/4.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AITransferPort.h"

/**
 *  MARK:--------------------H任务时使用 (参考33144-TODO1)--------------------
 */
@interface AITransferPort_H : AITransferPort

+(AITransferPort_H*) newWithFScene_H:(AIKVPointer*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIKVPointer*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps
                          fRScene:(AIFoNodeBase*)fRScene iRScene:(AIFoNodeBase*)iRScene;

/**
 *  MARK:--------------------用于H任务时,存I层和F层的RScene--------------------
 *  @desc 原本的scene和canset分别表示(最终canset和canset的scene),但H时,真正的IF场景树是再向上取一层的RScene;
 */
@property (strong, nonatomic) AIKVPointer *iRScene;
@property (strong, nonatomic) AIKVPointer *fRScene;

@end
