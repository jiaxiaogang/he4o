//
//  XGDebug.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "XGDebug.h"
#import "XGDebugModel.h"

@interface XGDebug ()

@property (assign, nonatomic) NSTimeInterval lastTime;
@property (strong, nonatomic) NSString *lastKey;
@property (strong, nonatomic) NSMutableArray *models;   //List<XGDebugModel>
@property (assign, nonatomic) NSInteger lastWriteCount;
@property (assign, nonatomic) NSInteger lastReadCount;

@end

@implementation XGDebug

static XGDebug *_instance;
+(XGDebug*) sharedInstance{
    if (_instance == nil) _instance = [[XGDebug alloc] init];
    return _instance;
}

//MARK:===============================================================
//MARK:                     < IN >
//MARK:===============================================================

/**
 *  MARK:--------------------追加一条记录--------------------
 *  @version
 *      2022.08.09: 废弃line代码行号,因为它做不参与到key防重,所以不唯一,所以不准且没用;
 */
-(void) debugModuleWithFileName:(NSString*)fileName suffix:(NSString*)suffix {
    fileName = STRTOOK(fileName);
    NSString *prefix = SUBSTR2INDEX(fileName, fileName.length - 2);
    [self debugModuleWithPrefix:prefix suffix:suffix];
}

-(void) debugModuleWithPrefix:(NSString*)prefix suffix:(NSString*)suffix {
    //0. 数据准备;
    prefix = STRTOOK(prefix);
    NSString *key = STRISOK(suffix) ? STRFORMAT(@"%@ 代码块:%@",prefix,suffix) : prefix;
    
    //1. 上帧结算;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 1000;
    if (self.lastKey && self.lastTime > 0) {
        
        //a. 旧有model;
        XGDebugModel *lastModel = ARR_INDEX([SMGUtils filterArr:self.models checkValid:^BOOL(XGDebugModel *item) {
            return [item.key isEqualToString:self.lastKey];
        }], 0);
        
        //b. 无则新建;
        if (!lastModel) {
            lastModel = [[XGDebugModel alloc] init];
            [self.models addObject:lastModel];
        }
        
        //c. 统计更新;
        lastModel.key = self.lastKey;
        lastModel.sumTime += now - self.lastTime;
        lastModel.sumCount++;
        lastModel.sumWriteCount += self.lastWriteCount;
        lastModel.sumReadCount += self.lastReadCount;
    }
    
    //2. 当前帧记录;
    self.lastKey = key;
    self.lastTime = now;
    self.lastWriteCount = 0;
    self.lastReadCount = 0;
}

-(void) debugWrite{
    self.lastWriteCount++;
}

-(void) debugRead{
    self.lastReadCount++;
}

-(NSMutableArray *)models{
    if (!_models) {
        _models = [[NSMutableArray alloc] init];
    }
    return _models;
}

//MARK:===============================================================
//MARK:                     < OUT >
//MARK:===============================================================

/**
 *  MARK:--------------------根据前辍取debugModels--------------------
 *  @desc 用于获取结果输出;
 *  @result notnull
 */
-(NSArray*) getDebugModels:(NSString*)prefix {
    prefix = STRTOOK(prefix);
    NSArray *result = [SMGUtils filterArr:self.models checkValid:^BOOL(XGDebugModel *item) {
        NSString *itemPrefix = [item.key substringWithRange:NSMakeRange(0, MIN(prefix.length, item.key.length))];
        return [prefix isEqualToString:itemPrefix];
    }];
    return result;
}

/**
 *  MARK:--------------------打印结果--------------------
 *  @version
 *      2023.06.13: 支持打印后直接将结果删除,因为代码块debug工具以loopId拼接key,这models越来越多,性能会变差 (参考30022-优化5);
 */
-(void) print:(NSString*)prefix rmPrefix:(NSString*)rmPrefix {
    NSArray *debugModels = [self getDebugModels:prefix];
    if (!ARRISOK(debugModels)) return;
    XGDebugModel *sum = [[XGDebugModel alloc] init];
    for (XGDebugModel *model in debugModels) {
        NSLog(@"%@ 计数:%ld 均耗:%.2f = 总耗:%.0f 读:%ld 写:%ld",model.key,model.sumCount,model.sumTime / model.sumCount,model.sumTime,model.sumReadCount,model.sumWriteCount);
        sum.sumCount += model.sumCount;
        sum.sumTime += model.sumTime;
        sum.sumReadCount += model.sumReadCount;
        sum.sumWriteCount += model.sumWriteCount;
    }
    NSLog(@"DEBUG匹配 => 总计数:%ld 均耗:%.2f = 总耗:%.0f 读:%ld 写:%ld",sum.sumCount,sum.sumTime / sum.sumCount,sum.sumTime,sum.sumReadCount,sum.sumWriteCount);
    
    //支持打印后将结果删除;
    if (STRISOK(rmPrefix)) {
        NSArray *rmModels = [self getDebugModels:rmPrefix];
        for (XGDebugModel *model in rmModels) {
            [self.models removeObject:model];
        }
        //NSLog(@"%@ -> 打印条数:%ld 删除条数:%lu 还剩条数: %lu",rmPrefix,debugModels.count,rmModels.count,self.models.count);
    }
}

@end
