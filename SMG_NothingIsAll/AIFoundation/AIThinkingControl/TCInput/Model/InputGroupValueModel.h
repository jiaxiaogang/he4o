//
//  InputDotModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------装箱后的组特征模型，用于表征除装箱后指针外，外加level粒度层级和xy位置信息--------------------
 */
@interface InputGroupValueModel : NSObject

+(id) new:(NSArray*)subDot_ps level:(NSInteger)level x:(NSInteger)x y:(NSInteger)y;

@property (assign, nonatomic) NSInteger level;//粒度级别（越大越细，越小越粗）
@property (assign, nonatomic) NSInteger x;//粒度级别（越大越细，越小越粗）
@property (assign, nonatomic) NSInteger y;//粒度级别（越大越细，越小越粗）
@property (strong, nonatomic) NSArray *subDot_ps;//子点稀疏码

@property (strong, nonatomic) AIGroupValueNode *groupValue;//用subDot_ps构建的组码。

@end
