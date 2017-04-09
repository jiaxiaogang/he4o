//
//  FeelModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------感觉码 模型--------------------
 */
@interface FeelModel : NSObject

@property (assign, nonatomic) NSInteger feelId;
@property (strong,nonatomic) NSMutableDictionary *attributes;

@end
