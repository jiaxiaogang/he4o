//
//  AIFeatureJvBuModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureJvBuModel.h"

@implementation AIFeatureJvBuModel

+(id) new:(AIFeatureNode*)assT {
    AIFeatureJvBuModel *result = [AIFeatureJvBuModel new];
    result.assT = assT;
    return result;
}

-(NSMutableArray *)bestGVs {
    if (!_bestGVs) _bestGVs = [NSMutableArray new];
    return _bestGVs;
}

-(void) run4MatchValueAndMatchDegreeAndMatchAssProtoRatio {
    self.matchValue = self.bestGVs.count == 0 ? 0 : [SMGUtils sumOfArr:self.bestGVs convertBlock:^double(AIFeatureJvBuItem *obj) {
        return obj.matchValue;
    }] / self.bestGVs.count;
    self.matchDegree = self.bestGVs.count == 0 ? 0 : [SMGUtils sumOfArr:self.bestGVs convertBlock:^double(AIFeatureJvBuItem *obj) {
        return obj.matchDegree;
    }] / self.bestGVs.count;
    
    //此处没有protoT.count，所以健全度直接用assCount也是不影响竞争的。
    self.matchAssProtoRatio = self.assT.count;
}

-(void) run4AssTAtProtoTRect {
    self.assTAtProtoTRect = CGRectNull;
    for (AIFeatureJvBuItem *item in self.bestGVs) {
        self.assTAtProtoTRect = CGRectUnion(self.assTAtProtoTRect, item.bestGVAtProtoTRect);
    }
}

@end
