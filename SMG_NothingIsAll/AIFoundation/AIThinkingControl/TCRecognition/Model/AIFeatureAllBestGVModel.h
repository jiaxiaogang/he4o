//
//  AIFeatureAllBestGVModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/24.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------把每一个protoT帧，下识别到的最好的一条item记录到此处，所有的best共同组成识别到的assT结果--------------------
 */
@interface AIFeatureAllBestGVModel : NSObject

@property (strong, nonatomic) NSMutableDictionary *bestDic;//竞争前收集Items：<K=assKey，V=Arr[AIFeatureNextGVRankItem]>
@property (strong, nonatomic) NSMutableDictionary *protoDic;//竞争前收集Items：<K=assKey，V=Arr[AIFeatureNextGVRankItem]>
@property (strong, nonatomic) NSMutableDictionary *rankDic; //竞争后最好Item：<K=assKey，V=best AIFeatureNextGVRankItem>

/**
 *  MARK:--------------------更新一条--------------------
 */
-(void) updateStep1:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree matchOfProtoIndex:(NSInteger)matchOfProtoIndex;

/**
 *  MARK:--------------------竞争只保留最好一条--------------------
 */
-(void) invokeRankStep2;

/**
 *  MARK:--------------------更新时，直接查下有没重复，有重复的就只保留更优的一条--------------------
 */
-(void) updateStep3;
-(void) updateStep3:(AIFeatureNextGVRankItem*)newItem forKey:(NSString*)assKey;
-(NSArray*) getAssGVModelsForKey:(NSString*)assKey;

/**
 *  MARK:--------------------把bestModel生成为AIMatchModel格式--------------------
 */
-(NSDictionary*) convert2AIMatchModelsStep4;

@end
