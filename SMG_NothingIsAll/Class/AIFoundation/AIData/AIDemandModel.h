//
//  AIDemand.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIDemandModel : AIObject

-(id) initWithAIMindValueModel:(AIMindValueModel*)model;
@property (assign, nonatomic) CGFloat value;
@property (assign, nonatomic) MindType type;

@end
