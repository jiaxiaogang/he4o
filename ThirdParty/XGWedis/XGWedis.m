//
//  XGWedis.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/5/7.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "XGWedis.h"
#import "XGRedisUtil.h"
#import "XGRedisDictionary.h"

@interface XGWedis ()

@property (strong, nonatomic) NSMutableDictionary *dic; //异步持久化核心字典
@property (strong,nonatomic) NSTimer *timer;            //计时器
@property (nonatomic, copy) XGWedisSaveBlock saveBlock; //持久化block

@end

@implementation XGWedis

static XGWedis *_instance;
+(XGWedis*) sharedInstance{
    if (_instance == nil) {
        _instance = [[XGWedis alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.dic = [[NSMutableDictionary alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(notificationTimer) userInfo:nil repeats:YES];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) setObject:(NSObject*)obj forKey:(NSString*)key {
    if (obj && STRISOK(key)) {
        [self.dic setObject:obj forKey:key];
    }
}

-(id) objectForKey:(NSString*)key{
    return [self.dic objectForKey:key];
}

-(void)setSaveBlock:(XGWedisSaveBlock)saveBlock{
    _saveBlock = saveBlock;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
- (void)notificationTimer{
    NSMutableDictionary *saveDic = [self.dic copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kXGWedisSaveObserver object:saveDic];
        if (self.delegate && [self.delegate respondsToSelector:@selector(xgWedis_Save:)]) {
            [self.delegate xgWedis_Save:saveDic];
        }
        if (self.saveBlock) {
            self.saveBlock(saveDic);
        }
        //dispatch_async(dispatch_get_main_queue(), ^{});
    });
    [self.dic removeAllObjects];
}


@end
