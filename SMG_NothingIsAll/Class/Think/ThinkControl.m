//
//  ThinkControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "ThinkControl.h"
#import "ThinkHeader.h"
#import "TestHungryPage.h"

@interface ThinkControl ()

@end

@implementation ThinkControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    
}

-(void) initRun{
    
}

/**
 *  MARK:--------------------Understand(Input->Think)--------------------
 *  副引擎
 *  浅理解/无意分析");//只取obj,char不存;
 *  与预测作比较;
 */
-(void) commitUnderstandByShallow:(id)data{
    if (STRISOK(data)) {
        [self commitUnderstandByDeep:data];//1,字符串每次都给予注意力;
    }else if(true){
        
    }else{
        
    }
}

-(void) commitUnderstandByDeep:(id)data{
    if (STRISOK(data)) {
        //收集charArr
        NSString *str = (NSString*)data;
        NSMutableArray *charArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < str.length; i++) {
            AIChar *c = AIMakeChar([str characterAtIndex:i]);
            [charArr addObject:c];
        }
        
        //记录规律
        AILawModel *law = AIMakeLawByArr(charArr);
        
        //问mind有没意见
        if (self.delegate && [self.delegate respondsToSelector:@selector(thinkControl_GetMindValue:)]) {
            id mindValue = [self.delegate thinkControl_GetMindValue:law.pointer];
            NSLog(@"%@",mindValue);
        }
        
        
        //1,理解data
            //1.1,通过关联网络取
            //1.2,尝试理解;(return "理解结果",1+1=1+1 || 1+1=2)
        //2,预测比较 || 经验比较
            //2.1,比较"理解结果"
        //3,mind界入干预
            //3.1,先不考虑
        
        
    }else{
        
    }
}

/**
 *  MARK:--------------------Demand(Mind->Think)--------------------
 */
-(void) commitMindValueNotice:(AIMindValueModel*)model{
    //1,数据检查
    if (model == nil) {
        return;
    }
    //2,通知时2选1;
    AIDemandModel *demandModel = [[AIDemandModel alloc] initWithAIMindValueModel:model];
    [AIDemandStore insert:demandModel awareness:true];//logThink记忆
    [self setData:demandModel];
}

-(void) commitMindModel:(id)m mindValueModel:(AIMindValueModel*)mindValudModel{
    if (!m) return;
    if (self.isBusy) return;//
    //...
}

/**
 *  MARK:--------------------Task--------------------
 */
//执行前分析任务可行性;
-(BOOL) checkTaskCanDecision:(AIDemandModel*)model{
    if (model) {
        
        //失效验证1,取当前状态等相关数据,进行分析;
        //link to Demand line69:-(BOOL) checkTaskValid:(AIMindValueModel*)model;
        
        //失效验证2,取AILine关联数据
        [AILineStore searchPointer:model.pointer count:1];//取多少呢?
        //必须先有解,才会有网络,才能分析认定这样的验证;(参考:AI/框架/Understand/ThinkDemand的解)
        //2.1,根据AILine查找数据;
        //2.2,带有目的性,只要找到已解的"意识流"数据;则中止;并返回false;
        
        
        //ThinkDemand的解;
        //1,依赖于经验等数据;
        //2,依赖与常识的简单解决方案;(类比)
        //3,复杂的问题分析(随后再写)
        
        
        
    }
    
    return true;
}

/**
 *  MARK:--------------------Decision--------------------
 */
-(void) decisionWithTask{
    //1,数据检查
    if (self.curDemand == nil) {
        return;
    }
    
    //3,分析问题;
    if (self.curDemand.type == MindType_Hunger) {//解决饿的问题
        CGFloat mindValueDelta = self.curDemand.value;
        
        if (fabs(mindValueDelta) > 1) {
            
            //LogThink开始思考问题;...........
            
            
            //1,搜索强化经验(经验表)
            BOOL experienceValue = [self decisionByExperience];
            if (experienceValue) {
                
                //1),参照解决方式,
                //2),类比其常识,
                //3),制定新的解决方式,
                //4),并分析其可行性, & 修正
                //5),预测其结果;(经验中上次的步骤对比)
                //6),执行输出;
            }else{
                //2,搜索未强化经历(意识流)
                BOOL memValue = [self decisionByMemory];
                if (memValue) {
                    //1),参照记忆,
                    //2),尝试执行输出;
                    //3),反馈(观察整个执行过程)
                    //4),强化(哪些步骤是必须,哪些步骤是有关,哪些步骤是无关)
                    //5),转移到经验表;
                }else{
                    //1),取原始情绪表达方式(哭,笑)(是急哭的吗?)
                    if ([self.delegate respondsToSelector:@selector(thinkControl_TurnDownDemand:)]) {
                        [self.delegate thinkControl_TurnDownDemand:self.curDemand];//2),执行输出;
                    }
                    //3),记忆(观察整个执行过程)
                }
            }
            //注:执行输出并非执行结束,任务达成才是结果;(输出只是执行的一部分)
            //注:当下AI只能输出文字;
        }
    }
}

-(BOOL) decisionByExperience{
    AIExperienceModel *value = [AIExperienceStore searchSingleRowId:1];
    return value != nil;
}

-(BOOL) decisionByCommonSense{
    AICommonSenseModel *value = [AICommonSenseStore searchSingleRowId:1];
    return value != nil;
}

-(BOOL) decisionByAwareness{
    AIAwarenessModel *value = [AIAwarenessStore searchSingleRowId:1];
    return value != nil;
}

-(BOOL) decisionByMemory{
    AIMemoryModel *value = [AIMemoryStore searchSingleRowId:1];
    return value != nil;
}

/**
 *  MARK:--------------------Other--------------------
 */
-(void) setData:(AIDemandModel *)demand{
    //1,检查demand有效性
    if (![self checkTaskCanDecision:demand]) return;
    
    //2,检查数据可替换
    BOOL valid = false;
    if (demand && self.curDemand) {
        if (demand.type == self.curDemand.type) {
            if (demand.value > 0 != self.curDemand.value > 0) {
                [self stopCurDemand];
                //从意识流Demand的解决到"抽象出常识";
                //"苹果可以吃"是有意识思考;//所以此处要产生一个有意识的思考;来抽象出"常识"数据;
                //最原始的数据存储;我吃过苹果;而不是苹果可以吃;
                //形成不同梯度的数据到底是AILine还是不同的表?
                //有可能只是神经网络的强度组成了不同的抽象层级;而不是不同的表;但抽象后,肯定是有数据的;(这里需要再做些思考)
            }
        }else{
            //1,curDemand依专注度x权重(意识流密度和数量,相关的mindValue)
            NSInteger curDemandV = fabs(self.curDemand.value);
            curDemandV *= 2.0f;
            
            //2,四舍五入
            NSInteger newDemandV = (int)(fabs(demand.value) + 0.5f);
            curDemandV = (int)(curDemandV + 0.5f);
            
            //3,对比
            if (newDemandV > curDemandV) {
                valid = true;
            }else if(newDemandV == curDemandV){
                //由Think决定:
                //a.再次搜索权重;
                //a.1;找不到时,思考解决方法;
                //a.2;更多线索;
                //a.3;随机挑一个;
            }else{
                
            }
        }
    }else{
        valid = true;
    }
    //3,替换
    if (valid) {
        _curDemand = demand;
        [[NSNotificationCenter defaultCenter] postNotificationName:ObsKey_ThinkBusy object:nil];
        [self decisionWithTask];
    }
}

-(BOOL) isBusy{
    return self.curDemand != nil;
}

-(void) stopCurDemand{
    _curDemand = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ObsKey_ThinkBusy object:nil];
}

@end
