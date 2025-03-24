//
//  AIFeatureNextGVRankModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/23.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------用于Feature识别时，收集下一点GV的竞争数据--------------------
 *  @desc 因为特征里的每一个组码，都要识别多个，并ref更多个，这些结果，要分别计算出：GV位置符合度，GV匹配度，将其收集起来，最后用于竞争，找出最准确的那一条refPort。
 */
@interface AIFeatureNextGVRankModel : NSObject

@property (strong, nonatomic) NSMutableDictionary *protoDic;//竞争前收集Items：<K=assKey，V=Arr[AIFeatureNextGVRankItem]>
@property (strong, nonatomic) NSMutableDictionary *rankDic; //竞争后最好Item：<K=assKey，V=best AIFeatureNextGVRankItem>

/**
 *  MARK:--------------------更新一条--------------------
 */
-(void) update:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree matchOfProtoIndex:(NSInteger)matchOfProtoIndex;

/**
 *  MARK:--------------------竞争只保留最好一条--------------------
 */
-(void) invokeRank;

@end
