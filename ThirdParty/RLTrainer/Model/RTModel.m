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
@property (assign, nonatomic) long long useTimed;           //已使用时间
@property (assign, nonatomic) long long lastStartTime;      //最后一次开始时间
@property (strong, nonatomic) NSString *invokingName;       //当前执行中name;

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

//单步训练执行完成报告;
-(void) invoked:(NSString*)name{
    if ([STRTOOK(name) isEqualToString:self.invokingName]) {
        self.invokingName = nil;
    }
}

-(void) clear{
    [self.queues removeAllObjects];
    self.queueIndex = 0;
    self.useTimed = 0;
    self.lastStartTime = 0;
}

//返回useTimed + 现在播放中已用时;
-(long long) getTotalUseTimed{
    if (self.lastStartTime > 0) {
        long long now = [[NSDate new] timeIntervalSince1970];
        return self.useTimed + now - self.lastStartTime;
    }
    return self.useTimed;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(void) invoke:(NSString*)name{
    NSInvocation *invc = [self.dic objectForKey:name];
    [invc invoke];
}

//暂停时,把最后一次训练用时收集到已用时:useTimed中;
-(void) pauseCollectUseTimed{
    if (self.lastStartTime > 0) {
        long long now = [[NSDate new] timeIntervalSince1970];
        self.useTimed += now - self.lastStartTime;
        self.lastStartTime = 0;
    }
}

//开始播放时,记下开始播放的时间;
-(void) playSetLastStartTime{
    if (self.lastStartTime == 0) {
        self.lastStartTime = [[NSDate new] timeIntervalSince1970];
    }
}

//MARK:===============================================================
//MARK:                     < block >
//MARK:===============================================================
-(void) timeBlock {
    //1. 不用执行: 非播放状态,return;
    if (![self.delegate rtModel_Playing]) {
        [self pauseCollectUseTimed];
        return;
    }
    
    //2. 不用执行: 执行播放完时,return;
    if (self.queueIndex == self.queues.count){
        [self pauseCollectUseTimed];
        [self.delegate rtModel_Finished];
        return;
    }
    
    //3. 意外>count时处理;
    if (self.queueIndex > self.queues.count) return;
    [self playSetLastStartTime];
    
    //4. 行为输出时,会即刻执行;
    NSString *name = ARR_INDEX(self.queues, self.queueIndex);
    BOOL runSoon = [name isEqualToString:kFlySEL];
    
    //5. 非即刻执行的命令,判断是否需要等待上一命令 || 等待思维空载;
    if (!runSoon) {
        //6. 没轮到下帧: 上帧还未执行完成时,等待完成再执行下帧;
        if (STRISOK(self.invokingName)) {
            NSLog(@"----> 强化训练_上帧执行中 -> 等待");
            return;
        }
        
        //7. 思维忙时没轮到下帧: TC忙碌状态则返回 (计数速率(负载)>10时,为忙状态);
        NSInteger operDelta = theTC.getOperCount - self.lastOperCount;
        self.lastOperCount = theTC.getOperCount;
        BOOL busyStatus = operDelta > 0;
        if (busyStatus) {
            NSLog(@"----> 强化训练_思维负载(%ld) -> 等待",operDelta);
            return;
        }
    }
    
    //8. 执行下帧;
    NSLog(@"强化训练 -> 执行:%@ (%ld/%ld)",name,self.queueIndex+1,self.queues.count);
    self.queueIndex++;
    self.invokingName = name;
    [self invoke:name];
    [self.delegate rtModel_Invoked];
}

@end
