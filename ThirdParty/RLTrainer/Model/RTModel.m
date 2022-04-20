//
//  RTModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RTModel.h"

#define TimerInterval 0.6f

@interface RTModel ()

@property (strong, nonatomic) NSMutableDictionary *dic;     //技能字典
@property (strong, nonatomic) NSMutableArray *queues;       //训练队列
@property (assign, nonatomic) NSInteger queueIndex;         //训练进度
@property (strong, nonatomic) NSTimer *timer;               //间隔计时器
@property (assign, nonatomic) long long lastOperCount;      //思维操作计数
@property (assign, nonatomic) double useTimed;              //已使用时间

@end

@implementation RTModel

-(id) init {
    self = [super init];
    if(self != nil){
        [self initData];
    }
    return self;
}

-(void) initData{
    self.dic = [[NSMutableDictionary alloc] init];
    self.queues = [[NSMutableArray alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TimerInterval target:self selector:@selector(timeBlock) userInfo:nil repeats:true];
}

//MARK:===============================================================
//MARK:                     < getset >
//MARK:===============================================================
-(NSMutableArray *)queues{
    return _queues;
}

-(NSInteger)queueIndex{
    return _queueIndex;
}

-(double)useTimed{
    return _useTimed;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector{
    
    //1. 获得类和方法的签名
    NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
    
    //2. 反射器;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    //3. 从签名获得调用对象
    [invocation setTarget:target];
    invocation.target = target;
    invocation.selector = selector;
    
    //4. 收集备用;
    [self.dic setObject:invocation forKey:name];
}

-(void) queue:(NSArray*)names count:(NSInteger)count{
    //1. 数据检查;
    names = ARRTOOK(names);
    
    //2. 更新训练队列;
    for (NSInteger i = 0; i < count; i++) {
        for (NSString *name in names) {
            [self.queues addObject:name];
        }
    }
}

-(void) clear{
    [self.queues removeAllObjects];
    self.queueIndex = 0;
    self.useTimed = 0;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) invoke:(NSString*)name{
    NSInvocation *invc = [self.dic objectForKey:name];
    [invc invoke];
}

//MARK:===============================================================
//MARK:                     < block >
//MARK:===============================================================
-(void) timeBlock {
    //1. 播放状态
    if (![self.delegate rtModel_Playing]) {
        NSLog(@"强化训练_非播放状态");
        return;
    }
    
    //2. 执行完时,返回;
    if (self.queueIndex >= self.queues.count) {
        return;
    }
    self.useTimed += TimerInterval;
    
    //3. TC忙碌状态则返回 (计数速率(负载)>10时,为忙状态);
    NSInteger operDelta = theTC.getOperCount - self.lastOperCount;
    BOOL busyStatus = operDelta > 3;
    self.lastOperCount = theTC.getOperCount;
    if (busyStatus) {
        NSLog(@"----> 强化训练_思维负载(%ld) -> 等待",operDelta);
        return;
    }
    
    //3. 执行下帧;
    NSString *name = ARR_INDEX(self.queues, self.queueIndex);
    NSLog(@"强化训练 -> 执行:%@ (%ld/%ld)",name,self.queueIndex+1,self.queues.count);
    self.queueIndex++;
    [self invoke:name];
    [self.delegate rtModel_Invoked];
}

@end
