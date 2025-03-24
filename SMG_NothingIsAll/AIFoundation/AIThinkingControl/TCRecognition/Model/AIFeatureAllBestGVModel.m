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

-(void) update:(AIFeatureNextGVRankItem*)item forKey:(NSString*)assKey {
    
}

-(NSArray*) getAssGVModelsForKey:(NSString*)assKey {
    return ARRTOOK([self.bestDic objectForKey:assKey]);
}

@end
