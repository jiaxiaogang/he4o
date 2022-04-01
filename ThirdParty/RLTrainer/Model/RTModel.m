//
//  RTModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "RTModel.h"

@interface RTModel ()

@property (strong, nonatomic) NSMutableDictionary *dic;     //技能字典
@property (strong, nonatomic) NSMutableArray *queues;       //训练队列
@property (assign, nonatomic) NSInteger queueIndex;         //训练进度
@property (strong, nonatomic) NSTimer *timer;               //间隔计时器
@property (assign, nonatomic) long long lastOperCount;      //思维操作计数

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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(timeBlock) userInfo:nil repeats:true];
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

-(void) queue:(NSString*)name count:(NSInteger)count{
    for (NSInteger i = 0; i < count; i++) {
        [self.queues addObject:name];
    }
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
    //1. TC忙碌状态则返回 (计数速率(负载)>10时,为忙状态);
    BOOL busyStatus = (theTC.getOperCount - self.lastOperCount) > 10;
    self.lastOperCount = theTC.getOperCount;
    if (busyStatus) {
        NSLog(@"忙碌_暂不执行队列");
        return;
    }
    
    //2. 执行中时,执行下帧;
    if (self.queueIndex < self.queues.count) {
        NSString *name = ARR_INDEX(self.queues, self.queueIndex);
        NSLog(@"执行队列:%ld/%ld => %@", self.queueIndex,self.queues.count, name);
        self.queueIndex++;
        [self invoke:name];
    }
}

@end
