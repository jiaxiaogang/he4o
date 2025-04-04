//
//  AIMatchModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/19.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------单条识别结果--------------------
 */
@interface AIMatchModel : NSObject

-(id) initWithMatch_p:(AIKVPointer*)match_p;

@property (strong, nonatomic) AIKVPointer *match_p; //匹配概念
@property (assign, nonatomic) CGFloat matchValue;   //相似度（乘积，默认为1）
@property (assign, nonatomic) NSInteger matchCount; //相似条数
@property (assign, nonatomic) CGFloat sumMatchValue;//总相似度（求平均相似度时，才会用到，乘积相似度用不着这个）
@property (assign, nonatomic) NSInteger sumRefStrong;

-(CGFloat) strongValue;
-(CGFloat) matchDegree;

@property (strong, nonatomic) NSDictionary *indexDic; //匹配到的映射 (k为assIndex,v为protoIndex)
@property (strong, nonatomic) NSDictionary *degreeDic;// <K=assIndex,V=matchDegree值>
@property (assign, nonatomic) CGFloat sumMatchDegree;//总符合度

@end
