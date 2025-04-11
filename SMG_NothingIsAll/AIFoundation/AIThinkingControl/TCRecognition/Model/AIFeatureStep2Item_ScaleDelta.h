//
//  AIFeatureStep2Item_ScaleDelta.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFeatureStep2Item_ScaleDelta : NSObject

+(AIFeatureStep2Item_ScaleDelta*) new:(NSInteger)absPId scale:(CGFloat)scale delta:(CGPoint)delta;

@property (assign, nonatomic) NSInteger absPId;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) CGPoint delta;

@end
