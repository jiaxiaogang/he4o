//
//  AIFeatureStep2Item_ScalaDelta.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFeatureStep2Item_ScalaDelta : NSObject

+(AIFeatureStep2Item_ScalaDelta*) new:(NSInteger)absPId scala:(CGFloat)scala delta:(CGPoint)delta;

@property (assign, nonatomic) NSInteger absPId;
@property (assign, nonatomic) CGFloat scala;
@property (assign, nonatomic) CGPoint delta;

@end
