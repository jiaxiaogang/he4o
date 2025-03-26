//
//  AIRecognitionCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIRecognitionCache.h"

static int hitNum,missNum;

@implementation AIRecognitionCache

+(id) getCache:(id)key cacheBlock:(id(^)())cacheBlock {
    //1. 数据准备。
    NSArray *inModels = [theTC.inModelManager.models copy];
    AIShortMatchModel *latestInModel = ARR_INDEX_REVERSE(inModels, 0);
    
    //1. 从瞬时序列里，找cache缓存。
    id value = nil;
    for (NSInteger i = 0; i < inModels.count; i++) {
        AIShortMatchModel *inModel = ARR_INDEX(inModels, i);
        value = [inModel.shortRecognitionCache objectForKey:key];
        
        //2. 如果找到退出循环。
        if (value) {
            
            //3. 如果是在早些复用过来的，则更新到最新的inModel中。
            if (i != inModels.count - 1) [latestInModel.shortRecognitionCache setObject:value forKey:key];
            break;
        }
    }
    
    //4. 记命中数。
    if (value) hitNum++; else missNum++;
    
    //5. 未命中，则执行加载。
    if (!value && cacheBlock) {
        value = cacheBlock();
        if (value) [latestInModel.shortRecognitionCache setObject:value forKey:key];
    }
    return value;
}

+(void) printLog:(BOOL)andReset {
    NSLog(@"识别缓存hit：%d miss：%d 命中率：%.2f",hitNum,missNum,hitNum + missNum > 0 ? (float)hitNum / (hitNum + missNum) : 0);
    if (andReset) {
        hitNum = 0;
        missNum = 0;
    }
}

@end
