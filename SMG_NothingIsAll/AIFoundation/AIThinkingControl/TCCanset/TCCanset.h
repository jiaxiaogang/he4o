//
//  TCCanset.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCanset : NSObject

/**
 *  MARK:--------------------将canset_p转成cansetModel--------------------
 */
+(TOFoModel*) convert2RCansetModel:(AIKVPointer*)cansetFrom_p fScene:(AIFoNodeBase*)fScene iScene:(AIFoNodeBase*)iScene basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel sceneModel:(AISceneModel*)sceneModel demand:(DemandModel*)demand;

/**
 *  MARK:--------------------HSolution转CansetModel--------------------
 */
+(TOFoModel*) convert2HCansetModelV2:(AIKVPointer *)hCansetFrom_p fScene:(AIFoNodeBase*)fScene hDemand:(HDemandModel *)hDemand hCansetCutIndex:(NSInteger)hCansetCutIndex targetFoM:(TOFoModel*)targetFoM hCansetToTargetIndex:(NSInteger)hCansetToTargetIndex IF_RSceneModel:(AISceneModel*)IF_RSceneModel xvModel:(TCTransferXvModel*)xvModel;

@end
