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

@property (strong, nonatomic) AIKVPointer *match_p; //匹配概念
@property (assign, nonatomic) CGFloat matchValue;   //相似度（乘积，默认为1）
@property (assign, nonatomic) NSInteger matchCount; //相似条数
@property (assign, nonatomic) NSInteger sumRefStrong;
-(CGFloat) strongValue;

@property (strong, nonatomic) NSDictionary *indexDic; //匹配到的映射 (k为assIndex,v为protoIndex)

@end
