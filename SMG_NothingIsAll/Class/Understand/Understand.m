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
    
    //2,MK数据
    __block NSMutableArray *findNewWordArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findOldWordArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findObjArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findDoArr = [[NSMutableArray alloc] init];
    for (FeelModel *model in modelArr) {
        if ([model isKindOfClass:[FeelTextModel class]]) {//字符串输入
            //1,收集保存分词数据
            FeelTextModel *textModel = ((FeelTextModel*)model);
            [UnderstandUtils getWordArrAtText:textModel.text outBlock:^(NSArray *oldWordArr, NSArray *newWordArr) {
                [findOldWordArr addObjectsFromArray:oldWordArr];
                NSArray *value = [[SMG sharedInstance].store.mkStore addWordArr:newWordArr];
                [findNewWordArr addObjectsFromArray:value];
            }];
        }else if ([model isKindOfClass:[FeelObjModel class]]) {//图像输入物体
            NSDictionary *value = [[SMG sharedInstance].store.mkStore addObj:((FeelObjModel*)model).name];
            [findObjArr addObject:value];
        }else if ([model isKindOfClass:[FeelDoModel class]]) {//图像输入行为
            NSDictionary *value = [[SMG sharedInstance].store.mkStore addDo:((FeelDoModel*)model).doType];
            [findDoArr addObject:value];
        }
    }
    
    //3,Mem数据
    NSMutableDictionary *memDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *memObjArr = [[NSMutableArray alloc] init];
    NSMutableArray *memDoArr = [[NSMutableArray alloc] init];
    for (FeelModel *model in modelArr) {
        if ([model isKindOfClass:[FeelTextModel class]]){
            //3.1,文本
            [memDic setObject:((FeelTextModel*)model).text forKey:@"text"];
        }else if ([model isKindOfClass:[FeelDoModel class]]) {//图像输入行为
            FeelDoModel *doModel = (FeelDoModel*)model;
            //3.2,如果doModel的fromMKId和toMKId是指向的名字;则这里修正为itemId;
            NSMutableDictionary *memDoItem = [[NSMutableDictionary alloc] init];
            for (NSDictionary *objItem in findObjArr) {
                if ([STRTOOK(doModel.fromMKId) isEqualToString:[objItem objectForKey:@"itemName"]]) {
                    [memDoItem setObject:STRTOOK([objItem objectForKey:@"itemId"]) forKey:@"fromId"];
                }
                if ([STRTOOK(doModel.toMKId) isEqualToString:[objItem objectForKey:@"itemName"]]) {
                    [memDoItem setObject:STRTOOK([objItem objectForKey:@"itemId"]) forKey:@"toId"];
                }
            }
            for (NSDictionary *findDoItem in findDoArr) {
                if ([STRTOOK(doModel.doType) isEqualToString:[findDoItem objectForKey:@"itemName"]]) {
                    [memDoItem setObject:STRTOOK([findDoItem objectForKey:@"itemId"]) forKey:@"doId"];
                }
            }
            [memDoArr addObject:memDoItem];
        }
    }
    [memDic setObject:memDoArr forKey:@"do"];
    //3.3,收集objId数组
    for (NSDictionary *item in findObjArr) {
        [memObjArr addObject:[item objectForKey:@"itemId"]];
    }
    [memDic setObject:memObjArr forKey:@"obj"];
    [[SMG sharedInstance].store.memStore addMemory:memDic];
    
    
    //4,MK_对应逻辑(实物<-->文字)
    for (NSString *objId in memObjArr) {
        [self understandObj:objId atText:@"" outBlock:^(NSMutableDictionary *linkDic) {
            if (linkDic) {
                for (NSString *key in linkDic.allKeys) {
                    NSDictionary *objItem = [linkDic objectForKey:key];
                    [[SMG sharedInstance].store.mkStore addWord:key withObjId:[objItem objectForKey:@"itemId"] withDoId:nil];
                }
            }
        }];
    }
    //5,MK_对应逻辑(行为<-->文字)(把行为与文字同时出现的规律记下来;等下次再出现行为文字变化,或出现文字,行为变化时;再分析do<-->word的关系;)
    for (NSDictionary *findDoItem in findDoArr) {
        [self understandDo:[findDoItem objectForKey:@"itemId"] outBlock:^(NSMutableDictionary *linkDic) {
            if (linkDic) {
                for (NSString *key in linkDic.allKeys) {
                    NSDictionary *doItem = [linkDic objectForKey:key];
                    [[SMG sharedInstance].store.mkStore addWord:key withObjId:nil withDoId:[doItem objectForKey:@"itemId"]];
                }
            }
        }];
    }
    
    //4.3,实物的行为逻辑;
    
    //4,Logic数据
    
    
}

/**
 *  MARK:--------------------private--------------------
 */

//MARK:----------找到新的单字分词----------
-(void) getSingleWordArrAtText:(NSString*)text outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr))outBlock{
    //有三次被孤立时,采用;
}

/**
 *  MARK:--------------------找obj的对应Text--------------------
 *  参数text:当前理解中记忆的text;先不需要;从记忆里活取;
 */
-(void) understandObj:(NSString*)objId atText:(NSString*)text outBlock:(void(^)(NSMutableDictionary *linkDic))outBlock{
    if (!STRISOK(objId)) return;
    NSMutableDictionary *valueDic = nil;
    //1,是否已被理解
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:objId,@"objId", nil];
    if ([[SMG sharedInstance].store.mkStore containerWordWithWhere:where]) {
        return;
    }
    //2,找相关的记忆数据
    NSMutableArray *dataArr = [UnderstandUtils getNeedUnderstandMemoryWithObjId:objId];
    //3,数据分解([{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}])
    NSMutableArray *objArrs = [[NSMutableArray alloc] init];
    NSMutableArray *doArrs = [[NSMutableArray alloc] init];
    NSMutableArray *wordArrs = [[NSMutableArray alloc] init];
    for (NSDictionary *item in dataArr) {
        [objArrs addObject:[item objectForKey:@"unknowObjArr"]];
        [doArrs addObject:[item objectForKey:@"unknowDoArr"]];
        [wordArrs addObject:[item objectForKey:@"unknowWordArr"]];
    }
    //4,数据比对obj<->word
    for (NSArray *objArrItem in objArrs) {
        for (NSString *objId in objArrItem) {
            NSMutableArray *linkArr = nil;
            for (NSArray *wordArrItem in wordArrs) {
                if (linkArr == nil) {
                    linkArr = [NSMutableArray arrayWithArray:wordArrItem];
                }else{
                    if (linkArr.count == 0) {
                        NSLog(@"此objId:%@__对应有空words",objId);
                        break;
                    }else{
                        for (NSInteger i = 0,max = linkArr.count; i < max; i++) {
                            if (![wordArrItem containsObject:linkArr[i]]) {
                                [linkArr removeObjectAtIndex:i];
                                max --;
                                i --;
                            }
                        }
                    }
                }
            }
            if (linkArr.count == 1) {
                NSLog(@"对应成功objId:%@___word:%@",objId,linkArr[0]);
                if (valueDic == nil) {
                    valueDic = [[NSMutableDictionary alloc] init];
                }
                [valueDic setObject:objId forKey:linkArr[0]];
            }
        }
    }
    //5,返回数据;
    if (outBlock) {
        outBlock (valueDic);
    }
}

//MARK:----------找do的对应Text----------
-(void) understandDo:(NSString*)doId outBlock:(void(^)(NSMutableDictionary *linkDic))outBlock{
    if (!STRISOK(doId)) return;
    NSMutableDictionary *valueDic = nil;
    //1,是否已被理解
    NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:doId,@"doId", nil];
    if ([[SMG sharedInstance].store.mkStore containerWordWithWhere:where]) {
        return;
    }
    //2,找相关的记忆数据
    NSMutableArray *dataArr = [UnderstandUtils getNeedUnderstandMemoryWithDoId:doId];
    //3,数据分解([{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}])
    NSMutableArray *objArrs = [[NSMutableArray alloc] init];
    NSMutableArray *doArrs = [[NSMutableArray alloc] init];
    NSMutableArray *wordArrs = [[NSMutableArray alloc] init];
    for (NSDictionary *item in dataArr) {
        [objArrs addObject:[item objectForKey:@"unknowObjArr"]];
        [doArrs addObject:[item objectForKey:@"unknowDoArr"]];
        [wordArrs addObject:[item objectForKey:@"unknowWordArr"]];
    }
    //4,数据比对do<->word
    for (NSArray *doArrItem in doArrs) {
        for (NSString *doId in doArrItem) {
            NSMutableArray *linkArr = nil;
            for (NSArray *wordArrItem in wordArrs) {
                if (linkArr == nil) {
                    linkArr = [NSMutableArray arrayWithArray:wordArrItem];
                }else{
                    if (linkArr.count == 0) {
                        NSLog(@"此doId:%@__对应有空words",doId);
                        break;
                    }else{
                        for (NSInteger i = 0,max = linkArr.count; i < max; i++) {
                            if (![wordArrItem containsObject:linkArr[i]]) {
                                [linkArr removeObjectAtIndex:i];
                                max --;
                                i --;
                            }
                        }
                    }
                }
            }
            if (linkArr.count == 1) {
                NSLog(@"对应成功doId:%@___word:%@",doId,linkArr[0]);
                if (valueDic == nil) {
                    valueDic = [[NSMutableDictionary alloc] init];
                }
                [valueDic setObject:linkArr[0] forKey:doId];
            }
        }
    }
    //5,返回数据;
    if (outBlock) {
        outBlock (valueDic);
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
        [UnderstandUtils getWordArrAtText:[mem objectForKey:@"text"] outBlock:^(NSArray *oldWordArr, NSArray *newWordArr) {
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
