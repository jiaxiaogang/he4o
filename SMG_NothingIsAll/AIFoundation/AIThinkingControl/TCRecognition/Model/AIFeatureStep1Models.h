//
//  AIFeatureStep1Models.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------局部特征识别V2算法模型：一级--------------------
 *  @desc 现在局部特征识别不再依赖protoT了，也没indexDic映射结果了，所以写下此模型，用于存识别中的数据，用于随后的整体特征识别和局部特征类比中要用。
 *  @desc 一级：没有protoT了，不过要为每个proto编号，在类比时避免类比错是哪一次识别的结果（可以用protoT.protoImgColorDic的hash编号）。
 *  @desc 二级：refPort.target、及每个targetAssT的最佳匹配到的gv数据bestGVs、存每个assT在proto中的rect（用于整体特征识别）。
 *  @desc 三级：存每一个匹配上的assIndex对应的：匹配度、符合度（用于类比）。
 */
@interface AIFeatureStep1Models : NSObject

+(id) new:(NSInteger)hash;

//protoT.protoImgColorDic的hash编号
@property (assign, nonatomic) NSInteger protoTHash;

//存识别结果：List<AIFeatureStep1Model>
@property (strong, nonatomic) NSMutableArray *models;

@end
