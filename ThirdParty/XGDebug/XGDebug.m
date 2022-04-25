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
@property (assign, nonatomic) NSInteger lastLine;
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

-(void) debugModule:(NSString*)name suffix:(NSString*)suffix line:(NSInteger)line{
    //0. 数据准备;
    name = STRTOOK(name);
    NSString *prefix = SUBSTR2INDEX(name, name.length - 2);
    NSString *key = STRISOK(suffix) ? STRFORMAT(@"%@_%@",prefix,suffix) : prefix;
    
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
        lastModel.line = self.lastLine;
        lastModel.sumTime += now - self.lastTime;
        lastModel.sumCount++;
        lastModel.sumWriteCount += self.lastWriteCount;
        lastModel.sumReadCount += self.lastReadCount;
    }
    
    //2. 当前帧记录;
    self.lastKey = key;
    self.lastLine = line;
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

@end
