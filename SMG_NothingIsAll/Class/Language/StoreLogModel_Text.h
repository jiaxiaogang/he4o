//
//  StoreLogModel_Text.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------文字交流(回复记录)模型--------------------
 */
@interface StoreLogModel_Text : NSObject

@property (strong,nonatomic) NSString *text;
@property (assign, nonatomic) float powerValue;   //权重 (sadHappyValue * 1 + useCount * 0.1f)

@end
