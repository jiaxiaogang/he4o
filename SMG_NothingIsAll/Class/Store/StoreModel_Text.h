//
//  StoreModel_Text.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------文字交流模型--------------------
 */
@interface StoreModel_Text : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSArray *logArr;   //回复记录

@end
