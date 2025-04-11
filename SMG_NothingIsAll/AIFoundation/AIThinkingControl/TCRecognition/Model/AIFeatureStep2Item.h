//
//  AIFeatureStep2Item.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:-------------------- 记录每一条abs在当前 assT/protoT 下的rect--------------------
 */
@interface AIFeatureStep2Item : NSObject

+(AIFeatureStep2Item*) new:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect;

//absT.pId
@property (assign, nonatomic) NSInteger absPId;

//conPort.rect（表示absT在assT/protoT中的位置）
@property (assign, nonatomic) CGRect absAtConRect;

@end
