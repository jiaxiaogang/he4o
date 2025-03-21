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

+(id) new:(NSArray*)subDots groupValue:(AIKVPointer*)groupValue_p level:(NSInteger)level x:(NSInteger)x y:(NSInteger)y;

@property (assign, nonatomic) NSInteger level;//粒度级别（越大越细，越小越粗）
@property (assign, nonatomic) NSInteger x;//粒度级别（越大越细，越小越粗）
@property (assign, nonatomic) NSInteger y;//粒度级别（越大越细，越小越粗）
@property (strong, nonatomic) NSArray *subDots;//子点稀疏码 (结果为：MapModel v1=单码指针 v2=自身x位置(取值范围0-2) v3=自身y位置(取值范围0-2)>

@property (strong, nonatomic) AIKVPointer *groupValue_p;//用subDot_ps构建的组码。
@property (assign, nonatomic) NSInteger matchOfProtoIndex;//与protoFeature的哪一帧匹配上的

@end
