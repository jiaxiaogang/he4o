//
//  AIOutputModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/13.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@interface AIOutputModel : AIObject

@property (assign, nonatomic) OutputType type;
@property (strong,nonatomic) NSObject *content;

@end
