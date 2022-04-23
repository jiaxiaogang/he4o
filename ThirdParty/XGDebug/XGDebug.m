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

@end

@implementation XGDebug

static XGDebug *_instance;
+(XGDebug*) sharedInstance{
    if (_instance == nil) _instance = [[XGDebug alloc] init];
    return _instance;
}

-(void) debug:(NSString*)key{
    //1. 上帧结算;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
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
        lastModel.key = key;
        lastModel.sumTime += now - self.lastTime;
        lastModel.sumCount++;
    }
    
    //2. 当前帧记录;
    self.lastKey = key;
    self.lastTime = now;
}

@end
