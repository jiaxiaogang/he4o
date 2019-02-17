//
//  AIThinkOutFoModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIThinkOutFoModel : NSObject

@property (strong, nonatomic) AIPointer *content_p;//对应的数据 (存AIFoNodeBase)
@property (strong, nonatomic) NSMutableArray *algModels;

@end
