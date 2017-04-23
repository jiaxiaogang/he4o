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
 *  3,更新记忆,MK;及逻辑推理记忆;
 *  4,根据Mind来调用OUTPUT;(表达语言,表达表情,下一次注意力采集信息)(这种采集分析采集分析的递归过程,发现和DeepMind/DNC里的架构很像)
 */
-(void) commitWithFeelModelArr:(NSArray*)modelArr{
    //1,数据检查
    if (!ARRISOK(modelArr)) {
        return;
    }
    //2,收集记忆数据
    NSMutableDictionary *memDic = [[NSMutableDictionary alloc] init];
    for (FeelModel *model in modelArr) {
        
        if ([feelModel isKindOfClass:[FeelTextModel class]]) {
            /*---------文字输入---------
             *
             *  1,存记忆
             *  2,存MK
             *      2.1,针对doModel的fromMKId和toMKId存MK;
             *  3,找出逻辑规律(语言规律,行为规律,语言中字词和行为的对称关系)
             *      3.1,例如:多次出现行为:'我' 吃 '瓜'  对应  textModel:我吃瓜
             *
             */
            
            //1,存记忆
            FeelTextModel *ftModel = (FeelTextModel*)feelModel;
            NSDictionary *mem = [NSDictionary dictionaryWithObjectsAndKeys:STRTOOK(ftModel.text),@"text",doModel,@"doModel", nil];
            [[SMG sharedInstance].store.memStore addMemory:mem];
            
            //2,存MK
            
            //3,Understand
            [[SMG sharedInstance].understand startUnderstand];
            
            
        }else if ([feelModel isKindOfClass:[FeelImgModel class]]) {
            //图像输入
        }else if ([feelModel isKindOfClass:[FeelAudioModel class]]) {
            //声音输入
        }
    }
}


//MARK:--------------------开始思考人生--------------------
-(void) startUnderstand{
    //1,分词:最近三条记忆;
    NSArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWhereDic:nil limit:3];
    for (int i = 0 ; i < memArr.count; i++) {
        NSDictionary *mem = memArr[memArr.count - i - 1];
        [self analyzeText:[mem objectForKey:@"text"]];
    }
    //2,行为<-->文字
    //2.1,有分词时,优先分词;
    //2.2,把行为与文字同时出现的规律记下来;等下次再出现行为文字变化,或出现文字,行为变化时;再分析do<-->word的关系;
    
    //3,联想
}

/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
//MARK:----------分析分词----------
-(NSArray*) analyzeText:(NSString*)text{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    text = STRTOOK(text);
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    //2,循环找text中的词
    for (int i = 0; i < text.length - 1; i++) {
        //双字词分析;
        NSString *checkWord = [text substringWithRange:NSMakeRange(i, 2)];
        if ([[SMG sharedInstance].store.mkStore containerWord:checkWord]) {
            [mArr addObject:checkWord]; //本来就有的词;
        }else{
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [[SMG sharedInstance].store.mkStore addWord:checkWord];
                [mArr addObject:checkWord];
            }
        }
    }
    return mArr;
}


-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end
