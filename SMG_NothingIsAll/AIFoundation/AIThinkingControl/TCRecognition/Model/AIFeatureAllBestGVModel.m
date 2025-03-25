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
 *  MARK:--------------------更新时，直接查下有没重复，有重复的就只保留更优的一条--------------------
 *  @desc STEP1. 新一条，判断是否更好，支持在所有protoIndex下，只保留一条。
 *  @desc 写该方法起因：一般是在特征识别时：多个protoIndex都ref到同一个target的同一帧（如果不去重，会导致特征映射不是一对一）。
 */
-(void) update:(NSString*)assKey refPort:(AIPort*)refPort gMatchValue:(CGFloat)gMatchValue gMatchDegree:(CGFloat)gMatchDegree matchOfProtoIndex:(NSInteger)matchOfProtoIndex {

    //2. newItem
    AIFeatureNextGVRankItem *item = [[AIFeatureNextGVRankItem alloc] init];
    item.refPort = refPort;
    item.gMatchValue = gMatchValue;
    item.gMatchDegree = gMatchDegree;
    item.matchOfProtoIndex = matchOfProtoIndex;
    [self update:item forKey:assKey];
}

-(void) update:(AIFeatureNextGVRankItem*)newItem forKey:(NSString*)assKey {
    //1. 找出已收集到的items。
    NSMutableArray *oldItems = [[NSMutableArray alloc] initWithArray:[self.bestDic objectForKey:assKey]];
    
    //2. 找出重复的oldItem（这里相当于指向同一个assIndex的只保留一条）。
    AIFeatureNextGVRankItem *oldItem = [SMGUtils filterSingleFromArr:oldItems checkValid:^BOOL(AIFeatureNextGVRankItem *oldItem) {
        return [oldItem.refPort isEqual:newItem.refPort];
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
-(NSDictionary*) convert2AIMatchModels {
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
        
        //TODOTOMORROW20250325: 把这个符合度存在哪合适？
        
        NSMutableDictionary *matchDegreeIndexDic = [[NSMutableDictionary alloc] init];
        for (AIFeatureNextGVRankItem *item in assGVItems) {
            AIFeatureNode *assT = [SMGUtils searchNode:item.refPort.target_p];
            
            //4. 收集总数据部分：每个assKey的识别assT结果，都要从其assGVItems的每一帧item结果中收集indexDic映射（根据refPort的level,x,y找其在assT中对应哪个assIndex）。
            NSInteger assIndex= [assT indexOfLevel:item.refPort.level x:item.refPort.x y:item.refPort.y];
            if (assIndex == -1) continue;
            [indexDic setObject:@(item.matchOfProtoIndex) forKey:@(assIndex)];
            //[matchDegreeIndexDic setObject:nil forKey:nil];待完成。
            
            //5. 直接到总账部分：resultDic用于统计匹配数，匹配度，总强度。
            tModel.match_p = assT.p;
            tModel.matchCount++;
            tModel.sumMatchValue += item.gMatchValue;
            tModel.sumMatchDegree += item.gMatchDegree;
            tModel.sumRefStrong += (int)item.refPort.strong.value;
        }
        
        //6. 把收集总数据计到总账：indexDic & 综合匹配度 & 符合度映射。
        tModel.matchValue = tModel.matchCount > 0 ? tModel.sumMatchValue / tModel.matchCount : 0;//综合求出平均matchValue（因为特征有太多组码，乘积匹配度不合理）。
        tModel.indexDic = indexDic;
    }
    return resultDic;
}

@end
