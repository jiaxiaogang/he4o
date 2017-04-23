//
//  Understand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "FeelHeader.h"
#import "UnderstandHeader.h"

@implementation Understand


-(id) init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) initData{
    self.timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(startUnderstand) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}


/**
 *  MARK:--------------------Feel交由Understand处理理解并存MK,Mem,Logic--------------------
 *  1,整理感觉系统传过来的数据;(属性,图像等)
 *  2,找出共同点与逻辑;
 *  3,更新记忆,MK;及逻辑推理记忆;(此方法不更,以后用到那条记忆时,再update)
 *  4,根据Mind来调用OUTPUT;(表达语言,表达表情,下一次注意力采集信息)(这种采集分析采集分析的递归过程,发现和DeepMind/DNC里的架构很像)
 *
 *  1,存MK(存MK,并生成mkId)
 *      1.1,找到MK则存;找不到不存;
 *      1.2,针对doModel:fromMKId和toMKId存MK_ImgStore DoType存到MK_AudioStore;
 *  2,存Logic(根据mkId更深了解逻辑,存Logic并生成LogicId)
 *      2.1,分析出逻辑则存,分析不到不存;
 *      2.2,找出逻辑规律(语言规律,行为规律,语言中字词和行为的对称关系)
 *      2.3,例如:多次出现行为:'我' 吃 '瓜'  对应  textModel:我吃瓜
 *  3,存Mem(并使用MKId和LogicId占位符)
 */
-(void) commitWithFeelModelArr:(NSArray*)modelArr{
    //1,数据检查
    if (!ARRISOK(modelArr)) {
        return;
    }
    
    //2,收集数据
    NSMutableDictionary *memDic = [[NSMutableDictionary alloc] init];
    __block NSArray *findNewWordArr = nil;
    __block NSArray *findOldWordArr = nil;
    
    
    for (FeelModel *model in modelArr) {
        if ([model isKindOfClass:[FeelTextModel class]]) {//字符串输入
            FeelTextModel *ftModel = (FeelTextModel*)model;
            //1,收集分词数据
            [self getWordArrAtText:ftModel.text outBlock:^(NSArray *oldWordArr, NSArray *newWordArr) {
                findNewWordArr = newWordArr;
                findOldWordArr = oldWordArr;
            }];
            
            //2,收集记忆数据
            [memDic setObject:STRTOOK(ftModel.text) forKey:@"text"];
        }else if ([model isKindOfClass:[FeelObjModel class]]) {//图像输入物体
            
        }else if ([model isKindOfClass:[FeelDoModel class]]) {//图像输入行为
            
        }
        
        //3,存数据
        [[SMG sharedInstance].store.mkStore addWordArr:findNewWordArr];
        [[SMG sharedInstance].store.memStore addMemory:memDic];
    }
    
    
    //3,Understand
    
    //2,行为<-->文字
    //2.1,有分词时,优先分词;
    //2.2,把行为与文字同时出现的规律记下来;等下次再出现行为文字变化,或出现文字,行为变化时;再分析do<-->word的关系;
    
    //3,联想
}

/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
//MARK:----------找到新的分词----------
-(void) getWordArrAtText:(NSString*)text outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr))outBlock{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *oldArr = [[NSMutableArray alloc] init];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    //2,循环找text中的新词
    for (int i = 0; i < text.length - 1; i++) {
        //双字词分析;
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        NSDictionary *findLocalWord = [[SMG sharedInstance].store.mkStore containerWord:checkWord];
        if (findLocalWord) {
            [oldArr addObject:findLocalWord];
        }else{
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [newArr addObject:checkWord];
            }
        }
    }
    //3,返回数据
    if (outBlock) {
        outBlock(oldArr,newArr);
    }
}

//MARK:----------找到新的逻辑----------
-(NSArray*) getNewLogicArrAtText:(NSString*)text{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    //2,循环找text中的新词
    for (int i = 0; i < text.length - 1; i++) {
        //双字词分析;
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        if (![[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [mArr addObject:checkWord];
            }
        }
    }
    return mArr;
}

/**
 *  MARK:--------------------min想--------------------
 */
-(void) startUnderstand{
    //1,分词:最近三条记忆;(这里以后改成,随机想一条逻辑线,即整理Mk又整理Logic)
    NSArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWhereDic:nil limit:3];
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < memArr.count; i++) {
        NSDictionary *mem = memArr[memArr.count - i - 1];
        [self getWordArrAtText:[mem objectForKey:@"text"] outBlock:^(NSArray *oldWordArr, NSArray *newWordArr) {
            [newWords addObjectsFromArray:newWordArr];
        }];
    }
    //2,存MK
    [[SMG sharedInstance].store.mkStore addWordArr:newWords];
    //3,存Logic
    //...
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end
