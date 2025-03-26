//
//  AIGroupValueNextVModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIGroupValueNextVModel.h"

@implementation AIGroupValueNextVModel

-(NSDictionary*) reloadEveryXYValidValue_ps:(NSArray*)firstGV_ps {
    if (!Switch4NextVModel) return nil;
    
    //1. 第0帧，取得的解，后面别的帧也都需要满足，才是有效的。
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (AIKVPointer *firstGV_p in firstGV_ps) {
        
        //2. 把每个解的别的xy坐标可能的解，各自收集起来（用于后面取交集）。
        AIGroupValueNode *firstGV = [SMGUtils searchNode:firstGV_p];
        for (NSInteger i = 0; i < firstGV.count; i++) {
            
            //3. 取得新的xyKey和content_p。
            AIKVPointer *content_p = ARR_INDEX(firstGV.content_ps, i);
            NSString *xyKey = STRFORMAT(@"%@_%@",ARR_INDEX(firstGV.xs, i),ARR_INDEX(firstGV.ys, i));
            
            //4. 新加到itemValue中。
            NSMutableArray *value = [result objectForKey:xyKey];
            if (!value) {
                value = [[NSMutableArray alloc] init];
                [result setObject:value forKey:xyKey];
            }
            if (![value containsObject:content_p]) [value addObject:content_p];
        }
    }
    self.everyXYValidValue_ps = result;
    return result;
}


-(NSArray*) getValidValue_ps:(NSInteger)x y:(NSInteger)y {
    return [self.everyXYValidValue_ps objectForKey:STRFORMAT(@"%ld_%ld",x,y)];
}

@end
