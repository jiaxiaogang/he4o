//
//  AIFeatureAllBestGVModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/24.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureAllBestGVModel.h"

@implementation AIFeatureAllBestGVModel

-(NSMutableDictionary *)bestDic {
    if (!_bestDic) _bestDic = [[NSMutableDictionary alloc] init];
    return _bestDic;
}

/**
 *  MARK:--------------------更新一条--------------------
 *  @desc STEP1. 在特征识别的protoIndex下，收集所有可能的下一点匹配。
 */
-(void) updateStep1:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree matchOfProtoIndex:(NSInteger)matchOfProtoIndex {
    //1. 数据检查
    if (!self.protoDic) self.protoDic = [[NSMutableDictionary alloc] init];
    
    //2. newItem
    AIFeatureNextGVRankItem *item = [[AIFeatureNextGVRankItem alloc] init];
    item.refPort = refPort;
    item.gMatchValue = gMatchValue;
    item.gMatchDegree = gMatchDegree;
    item.matchOfProtoIndex = matchOfProtoIndex;
    
    //3. add to items then add to dic;
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.protoDic objectForKey:assKey]];
    [items addObject:item];
    [self.protoDic setObject:items forKey:assKey];
}

/**
 *  MARK:--------------------竞争只保留最好一条--------------------
 *  @desc STEP2. 把STEP1收集到的，在当前protoIndex下，竞争只保留一条。
 */
-(void) invokeRankStep2 {
    //1. 数据准备
    self.rankDic = [[NSMutableDictionary alloc] init];
    
    //2. 每个items都竞争下best一条。
    for (NSString *assKey in self.protoDic.allKeys) {
        NSArray *items = ARRTOOK([self.protoDic objectForKey:assKey]);
        AIFeatureNextGVRankItem *bestItem =[SMGUtils filterBestObj:items scoreBlock:^CGFloat(AIFeatureNextGVRankItem *item) {
            return item.gMatchDegree * item.gMatchValue;
        }];
        if (!bestItem) continue;
        
        //3. 每个items只保留最best一条。
        [self.rankDic setObject:bestItem forKey:assKey];
    }
    
    //4. 清空protoDic;
    [self.protoDic removeAllObjects];
}

/**
 *  MARK:--------------------更新时，直接查下有没重复，有重复的就只保留更优的一条--------------------
 *  @desc STEP1. 新一条，判断是否更好，支持在所有protoIndex下，只保留一条。
 *  @desc 写该方法起因：一般是在特征识别时：多个protoIndex都ref到同一个target的同一帧（如果不去重，会导致特征映射不是一对一）。
 */
-(void) updateStep3 {
    //1. 跨protoIndex防重，将best结果存下来
    for (NSString *assKey in self.rankDic.allKeys) {
        AIFeatureNextGVRankItem *item = [self.rankDic objectForKey:assKey];
        
        //2. 明细：bestModel保证最匹配度&符合度，的每一条（且不会重复）。bestItem进阶成功，转存到最终gvBestModel中（后面用于判断xy相似度要用）（参考34052-TODO4）。
        [self updateStep3:item forKey:assKey];
    }
    
    //3. 清空rankDic;
    [self.rankDic removeAllObjects];
}
-(void) updateStep3:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree matchOfProtoIndex:(NSInteger)matchOfProtoIndex {

    //2. newItem
    AIFeatureNextGVRankItem *item = [[AIFeatureNextGVRankItem alloc] init];
    item.refPort = refPort;
    item.gMatchValue = gMatchValue;
    item.gMatchDegree = gMatchDegree;
    item.matchOfProtoIndex = matchOfProtoIndex;
    [self updateStep3:item forKey:assKey];
}

-(void) updateStep3:(AIFeatureNextGVRankItem*)newItem forKey:(NSString*)assKey {
    //1. 找出已收集到的items。
    NSMutableArray *oldItems = [[NSMutableArray alloc] initWithArray:[self.bestDic objectForKey:assKey]];
    
    //2. 找出重复的oldItem（这里相当于指向同一个assIndex的只保留一条）。
    AIFeatureNextGVRankItem *oldItem = [SMGUtils filterSingleFromArr:oldItems checkValid:^BOOL(AIFeatureNextGVRankItem *oldItem) {
        return [oldItem.refPort isEqual:newItem.refPort];// || newItem.matchOfProtoIndex == oldItem.matchOfProtoIndex;（如果把proto和rank两步去掉，则可能protoIndex重复收集，此处打开这个protoIndex判断可以用来防重）
    }];
    
    //3. 重复的没新的好，则去掉重复的留下新的。
    if (oldItem) {
        if (oldItem.gMatchValue * oldItem.gMatchDegree < newItem.gMatchValue * newItem.gMatchDegree) {
            [oldItems removeObject:oldItem];
            [oldItems addObject:newItem];
        }
    } else {
        //4. 没重复的，则直接留下新的。
        [oldItems addObject:newItem];
    }
    [self.bestDic setObject:oldItems forKey:assKey];
}

-(NSArray*) getAssGVModelsForKey:(NSString*)assKey {
    return ARRTOOK([self.bestDic objectForKey:assKey]);
}

/**
 *  MARK:--------------------把bestModel生成为AIMatchModel格式--------------------
 *  @desc STEP2. 把STEP1得到的proto和ass一一对应的结果，转成识别算法需要的AIMatchModels格式。
 */
-(NSDictionary*) convert2AIMatchModelsStep4 {
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    for (NSString *assKey in self.bestDic.allKeys) {
        
        //1. 建空总账：resultDic用于统计匹配数，匹配度，总强度。
        AIMatchModel *tModel = [resultDic objectForKey:assKey];
        if (!tModel) tModel = [[AIMatchModel alloc] init];
        [resultDic setObject:tModel forKey:assKey];
        
        //2. 查出明细：取出每一条防重后的最优匹配结果。
        NSArray *assGVItems = [self getAssGVModelsForKey:assKey];
        
        //3. 循环把明细记录到总账 或 收集总数据。
        NSMutableDictionary *indexDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *degreeDic = [[NSMutableDictionary alloc] init];
        for (AIFeatureNextGVRankItem *item in assGVItems) {
            AIFeatureNode *assT = [SMGUtils searchNode:item.refPort.target_p];
            
            //4. 收集总数据部分：每个assKey的识别assT结果，都要从其assGVItems的每一帧item结果中收集indexDic映射（根据refPort的level,x,y找其在assT中对应哪个assIndex）。
            NSInteger assIndex= [assT indexOfLevel:item.refPort.level x:item.refPort.x y:item.refPort.y];
            if (assIndex == -1) continue;
            [indexDic setObject:@(item.matchOfProtoIndex) forKey:@(assIndex)];
            
            //5. 把这个符合度像indexDic一样存，不需要存硬盘，只存内存就够用（在类比时复用一下）（参考34072-优化1）。
            [degreeDic setObject:@(item.gMatchDegree) forKey:@(assIndex)];
            
            //5. 直接到总账部分：resultDic用于统计匹配数，匹配度，总强度。
            tModel.match_p = assT.p;
            tModel.matchCount++;
            tModel.sumMatchValue += item.gMatchValue;
            tModel.sumMatchDegree += item.gMatchDegree;
            tModel.sumRefStrong += (int)item.refPort.strong.value;
        }
        
        //6. 把收集总数据计到总账：indexDic & 综合匹配度 & 符合度映射。
        tModel.matchValue = tModel.matchCount > 0 ? (tModel.sumMatchValue / tModel.matchCount) * (tModel.sumMatchDegree / tModel.matchCount) : 0;//综合求出平均matchValue（因为特征有太多组码，乘积匹配度不合理）。
        tModel.indexDic = indexDic;
        tModel.degreeDic = degreeDic;
    }
    return resultDic;
}

@end
