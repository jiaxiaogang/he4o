//
//  AIFeatureStep1Model.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep1Model.h"

@implementation AIFeatureStep1Model

+(id) new:(AIFeatureNode*)assT {
    AIFeatureStep1Model *result = [AIFeatureStep1Model new];
    result.assT = assT;
    return result;
}

-(NSMutableArray *)bestGVs {
    if (!_bestGVs) _bestGVs = [NSMutableArray new];
    return _bestGVs;
}

-(void) run4MatchValueAndMatchDegreeAndMatchAssProtoRatio {
    self.matchValue = self.bestGVs.count == 0 ? 0 : [SMGUtils sumOfArr:self.bestGVs convertBlock:^double(AIFeatureStep1Item *obj) {
        return obj.matchValue;
    }] / self.bestGVs.count;
    self.matchDegree = self.bestGVs.count == 0 ? 0 : [SMGUtils sumOfArr:self.bestGVs convertBlock:^double(AIFeatureStep1Item *obj) {
        return obj.matchDegree;
    }] / self.bestGVs.count;
    
    //此处没有protoT.count，所以健全度直接用assCount也是不影响竞争的。
    self.matchAssProtoRatio = self.assT.count;
}

@end
