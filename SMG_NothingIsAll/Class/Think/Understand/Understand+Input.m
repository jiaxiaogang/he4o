//
//  Understand+Input.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand+Input.h"
#import "FeelHeader.h"
#import "UnderstandHeader.h"



/**
 *  MARK:--------------------输入理解--------------------
 *
 *
 *
 */
@implementation Understand (INPUT)

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
 *
 *
 *  工作流程:
 *      1,根据多次出现找分词;(sumNone>=10||sumOne>=6||sumTwo>=3)
 *      2,分词已知时,与实物或行为对应;(记忆中实物行为和<3,未理解的分词数量与实物行为和差值<2)
 *
 */
-(void) commitWithFeelModelArr:(NSArray*)modelArr{
    //1,数据检查
    if (!ARRISOK(modelArr)) {
        return;
    }
    
    //2,收集数据Text,Obj,Do(Obj和Do存储)
    __block NSMutableArray *findObjArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findDoArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findTextArr = [[NSMutableArray alloc] init];
    for (FeelModel *model in modelArr) {
        if ([model isKindOfClass:[FeelTextModel class]]){
            //字符串输入
            NSString *text = ((FeelTextModel*)model).text;
            [findTextArr addObject:STRTOOK(text)];
        }else if ([model isKindOfClass:[FeelObjModel class]]) {
            //图像输入物体
            NSDictionary *value = [[SMG sharedInstance].store.mkStore.objStore addItem:((FeelObjModel*)model).name];
            if (value) [findObjArr addObject:value];
        }else if ([model isKindOfClass:[InputDoModel class]]) {
            //图像输入行为
            NSDictionary *value = [[SMG sharedInstance].store.mkStore.doStore addItem:((InputDoModel*)model).doType];
            if (value) [findDoArr addObject:value];
            
            NSDictionary *fromObj = [[SMG sharedInstance].store.mkStore.objStore addItem:((InputDoModel*)model).fromMKId];
            if (fromObj) [findObjArr addObject:fromObj];
            
            NSDictionary *toObj = [[SMG sharedInstance].store.mkStore.objStore addItem:((InputDoModel*)model).toMKId];
            if (toObj) [findObjArr addObject:toObj];
        }
    }
    
    
    //3,MK_Word理解分词并存储
    __block NSMutableArray *findNewWordArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *findOldWordArr = [[NSMutableArray alloc] init];
    NSMutableArray *forceWordArr = [[NSMutableArray alloc] init];//收集记忆中已成词
    for (NSDictionary *item in findObjArr){
        NSInteger objId = [STRTOOK([item objectForKey:@"itemId"]) integerValue];
        NSMutableArray *wordArr = [TextStore getWordArrWithObjId:objId];
        for (TextModel *model in wordArr) {
            [forceWordArr addObject:STRTOOK(model.text)];
        }
    }
    for (NSDictionary *item in findDoArr){
        NSInteger doId = [STRTOOK([item objectForKey:@"itemId"]) integerValue];
        NSMutableArray *wordArr = [TextStore getWordArrWithDoId:doId];
        for (TextModel *model in wordArr) {
            [forceWordArr addObject:STRTOOK(model.text)];
        }
    }
    for (NSString *text in findTextArr) {
        //收集保存分词数据
        [UnderstandUtils getWordArrAtText:text forceWordArr:forceWordArr outBlock:^(NSArray *oldWordArr, NSArray *newWordArr,NSInteger unknownCount){
            [findOldWordArr addObjectsFromArray:oldWordArr];
            NSArray *value = [TextStore addWordWithTextArr:newWordArr];
            [findNewWordArr addObjectsFromArray:value];
        }];
    }
    
    //4,Mem数据和存储
    NSMutableDictionary *memDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *memObjArr = [[NSMutableArray alloc] init];
    NSMutableArray *memDoArr = [[NSMutableArray alloc] init];
    for (FeelModel *model in modelArr) {
        if ([model isKindOfClass:[FeelTextModel class]]){//文本
            [memDic setObject:((FeelTextModel*)model).text forKey:@"text"];
        }else if ([model isKindOfClass:[InputDoModel class]]) {//图像输入行为(如果doModel的fromMKId和toMKId是指向的名字;则这里修正为itemId;)
            InputDoModel *doModel = (InputDoModel*)model;
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
    for (NSDictionary *item in findObjArr) {//收集objId数组
        [memObjArr addObject:[item objectForKey:@"itemId"]];
    }
    [memDic setObject:memObjArr forKey:@"obj"];
    [[SMG sharedInstance].store.memStore addMemory:memDic];
    
    
    //5,MK_对应逻辑(实物<-->文字)
    for (NSString *objId in memObjArr) {
        [self understandObj:objId atText:@"" outBlock:^(NSMutableDictionary *linkDic) {
            if (linkDic) {
                for (NSString *key in linkDic.allKeys) {
                    TextModel *textModel = [linkDic objectForKey:key];//本来就是本地的,不用再存;
                    NSInteger objId = [key integerValue];
                    
                    //创建两个指针
                    AIPointer *textPoint = [AIPointer initWithClass:TextModel.class withId:textModel.rowid];
                    AIPointer *objPoint = [AIPointer initWithClass:ObjModel.class withId:objId];
                    
                    //创建规律,并传入两个指针;
                    LawModel *lModel = [LawModel initWithAIPointers:textPoint,objPoint];
                    [LawStore insertToDB_LawModel:lModel];
                }
            }
        }];
    }
    //6,MK_对应逻辑(行为<-->文字)(把行为与文字同时出现的规律记下来;等下次再出现行为文字变化,或出现文字,行为变化时;再分析do<-->word的关系;)
    for (NSDictionary *findDoItem in findDoArr) {
        [self understandDo:[findDoItem objectForKey:@"itemId"] atText:[memDic objectForKey:@"text"] outBlock:^(NSMutableDictionary *linkDic) {
            if (linkDic) {
                for (NSString *key in linkDic.allKeys) {
                    TextModel *textModel = [linkDic objectForKey:key];//本来就是本地的,不用再存;
                    NSInteger doId = [key integerValue];
                    
                    //创建两个指针
                    AIPointer *textPoint = [AIPointer initWithClass:TextModel.class withId:textModel.rowid];
                    AIPointer *doPoint = [AIPointer initWithClass:DoModel.class withId:doId];
                    
                    //创建规律,并传入两个指针;
                    LawModel *lModel = [LawModel initWithAIPointers:textPoint,doPoint];
                    [LawStore insertToDB_LawModel:lModel];
                }
            }
        }];
    }
    
    //7,Logic逻辑;(MK<->因果)
    //a,归纳
        //苹果类;及属性特征
    //b,类比
        //总结规律
    //c,纠错机制
        //知识进化
        //遗忘及记忆加强机制(熟能生巧)
        //信息来源(兼听则明)
        //穷举共存(全部结果,共存共生)
    
}

//-(void) commitWithFeelModel:(FeelModel*)model{
//    //1,数据检查
//    if (model == nil) {
//        return;
//    }
//    
//    //2,收集数据
//    NSInteger groupId = [MemStore createGroupId];
//    if ([model isKindOfClass:[FeelTextModel class]]) {
//        NSString *text = ((FeelTextModel*)model).text;
//        for (NSInteger i = 0; i < text.length; i++) {
//            NSString *value = [text substringWithRange:NSMakeRange(i,1)];
//            CharModel *charModel = [CharStore createInstanceModel:value];
//            
//            MemModel *sayItemModel = [[MemModel alloc] init];
//            sayItemModel.groupId = groupId;
//            sayItemModel.objRowId = aObj.rowid;
//            sayItemModel.charRowId = charModel.rowid;
//            [MemModel insertToDB:sayItemModel];
//        }
//        
//    }else if ([model isKindOfClass:[FeelObjModel class]]) {
//        //图像输入物体
//        NSDictionary *value = [[SMG sharedInstance].store.mkStore addObj:((FeelObjModel*)model).name];
//        if (value) [findObjArr addObject:value];
//    }else if ([model isKindOfClass:[InputDoModel class]]) {
//        //图像输入行为
//        NSDictionary *value = [[SMG sharedInstance].store.mkStore addDo:((InputDoModel*)model).doType];
//        if (value) [findDoArr addObject:value];
//        
//        NSDictionary *fromObj = [[SMG sharedInstance].store.mkStore addObj:((InputDoModel*)model).fromMKId];
//        if (fromObj) [findObjArr addObject:fromObj];
//        
//        NSDictionary *toObj = [[SMG sharedInstance].store.mkStore addObj:((InputDoModel*)model).toMKId];
//        if (toObj) [findObjArr addObject:toObj];
//    }
//    
//    
//    //2,收集数据Text,Obj,Do(Obj和Do存储)
//    __block NSMutableArray *findObjArr = [[NSMutableArray alloc] init];
//    __block NSMutableArray *findDoArr = [[NSMutableArray alloc] init];
//    __block NSMutableArray *findTextArr = [[NSMutableArray alloc] init];
//    for (FeelModel *model in modelArr) {
//        if ([model isKindOfClass:[FeelTextModel class]]){
//            //字符串输入
//            NSString *text = ((FeelTextModel*)model).text;
//            [findTextArr addObject:STRTOOK(text)];
//        }else if ([model isKindOfClass:[FeelObjModel class]]) {
//            //图像输入物体
//            NSDictionary *value = [[SMG sharedInstance].store.mkStore addObj:((FeelObjModel*)model).name];
//            if (value) [findObjArr addObject:value];
//        }else if ([model isKindOfClass:[InputDoModel class]]) {
//            //图像输入行为
//            NSDictionary *value = [[SMG sharedInstance].store.mkStore addDo:((InputDoModel*)model).doType];
//            if (value) [findDoArr addObject:value];
//            
//            NSDictionary *fromObj = [[SMG sharedInstance].store.mkStore addObj:((InputDoModel*)model).fromMKId];
//            if (fromObj) [findObjArr addObject:fromObj];
//            
//            NSDictionary *toObj = [[SMG sharedInstance].store.mkStore addObj:((InputDoModel*)model).toMKId];
//            if (toObj) [findObjArr addObject:toObj];
//        }
//    }
//    
//    
//    //3,MK_Word理解分词并存储
//    __block NSMutableArray *findNewWordArr = [[NSMutableArray alloc] init];
//    __block NSMutableArray *findOldWordArr = [[NSMutableArray alloc] init];
//    NSMutableArray *forceWordArr = [[NSMutableArray alloc] init];//收集记忆中已成词
//    for (NSDictionary *item in findObjArr){
//        NSDictionary *where = [[NSDictionary alloc] initWithObjectsAndKeys:STRTOOK([item objectForKey:@"itemId"]),@"objId", nil];
//        NSMutableArray *wordArr = [[SMG sharedInstance].store.mkStore.textStore getWordArrWithWhere:where];
//        for (NSDictionary *wordDic in wordArr) {
//            [forceWordArr addObject:STRTOOK([wordDic objectForKey:@"word"])];
//        }
//    }
//    for (NSDictionary *item in findDoArr){
//        NSDictionary *where = [[NSDictionary alloc] initWithObjectsAndKeys:STRTOOK([item objectForKey:@"itemId"]),@"doId", nil];
//        NSMutableArray *wordArr = [[SMG sharedInstance].store.mkStore.textStore getWordArrWithWhere::where];
//        for (NSDictionary *wordDic in wordArr) {
//            [forceWordArr addObject:STRTOOK([wordDic objectForKey:@"word"])];
//        }
//    }
//    for (NSString *text in findTextArr) {
//        //收集保存分词数据
//        [UnderstandUtils getWordArrAtText:text forceWordArr:forceWordArr outBlock:^(NSArray *oldWordArr, NSArray *newWordArr,NSInteger unknownCount){
//            [findOldWordArr addObjectsFromArray:oldWordArr];
//            NSArray *value = [[SMG sharedInstance].store.mkStore.textStore addWordArr:newWordArr];
//            [findNewWordArr addObjectsFromArray:value];
//        }];
//    }
//    
//    //4,Mem数据和存储
//    NSMutableDictionary *memDic = [[NSMutableDictionary alloc] init];
//    NSMutableArray *memObjArr = [[NSMutableArray alloc] init];
//    NSMutableArray *memDoArr = [[NSMutableArray alloc] init];
//    for (FeelModel *model in modelArr) {
//        if ([model isKindOfClass:[FeelTextModel class]]){//文本
//            [memDic setObject:((FeelTextModel*)model).text forKey:@"text"];
//        }else if ([model isKindOfClass:[InputDoModel class]]) {//图像输入行为(如果doModel的fromMKId和toMKId是指向的名字;则这里修正为itemId;)
//            InputDoModel *doModel = (InputDoModel*)model;
//            NSMutableDictionary *memDoItem = [[NSMutableDictionary alloc] init];
//            for (NSDictionary *objItem in findObjArr) {
//                if ([STRTOOK(doModel.fromMKId) isEqualToString:[objItem objectForKey:@"itemName"]]) {
//                    [memDoItem setObject:STRTOOK([objItem objectForKey:@"itemId"]) forKey:@"fromId"];
//                }
//                if ([STRTOOK(doModel.toMKId) isEqualToString:[objItem objectForKey:@"itemName"]]) {
//                    [memDoItem setObject:STRTOOK([objItem objectForKey:@"itemId"]) forKey:@"toId"];
//                }
//            }
//            for (NSDictionary *findDoItem in findDoArr) {
//                if ([STRTOOK(doModel.doType) isEqualToString:[findDoItem objectForKey:@"itemName"]]) {
//                    [memDoItem setObject:STRTOOK([findDoItem objectForKey:@"itemId"]) forKey:@"doId"];
//                }
//            }
//            [memDoArr addObject:memDoItem];
//        }
//    }
//    [memDic setObject:memDoArr forKey:@"do"];
//    for (NSDictionary *item in findObjArr) {//收集objId数组
//        [memObjArr addObject:[item objectForKey:@"itemId"]];
//    }
//    [memDic setObject:memObjArr forKey:@"obj"];
//    [[SMG sharedInstance].store.memStore addMemory:memDic];
//    
//    
//    //5,MK_对应逻辑(实物<-->文字)
//    for (NSString *objId in memObjArr) {
//        [self understandObj:objId atText:@"" outBlock:^(NSMutableDictionary *linkDic) {
//            if (linkDic) {
//                for (NSString *key in linkDic.allKeys) {
//                    NSDictionary *wordItem = [linkDic objectForKey:key];
//                    NSString *objId = key;
//                    NSString *word = [wordItem objectForKey:@"word"];
//                    [[SMG sharedInstance].store.mkStore addWord:word withObjId:objId withDoId:nil];
//                }
//            }
//        }];
//    }
//    //6,MK_对应逻辑(行为<-->文字)(把行为与文字同时出现的规律记下来;等下次再出现行为文字变化,或出现文字,行为变化时;再分析do<-->word的关系;)
//    for (NSDictionary *findDoItem in findDoArr) {
//        [self understandDo:[findDoItem objectForKey:@"itemId"] atText:[memDic objectForKey:@"text"] outBlock:^(NSMutableDictionary *linkDic) {
//            if (linkDic) {
//                for (NSString *key in linkDic.allKeys) {
//                    NSDictionary *wordItem = [linkDic objectForKey:key];
//                    NSString *doId = key;
//                    NSString *word = [wordItem objectForKey:@"word"];
//                    [[SMG sharedInstance].store.mkStore addWord:word withObjId:nil withDoId:doId];
//                }
//            }
//        }];
//    }
//    
//    //7,Logic逻辑;(MK<->因果)
//    
//    
//}



/**
 *  MARK:--------------------private--------------------
 */
/**
 *  MARK:--------------------找obj的对应Text--------------------
 *  参数text:当前理解中记忆的text;先不需要;从记忆里活取;
 */
-(void) understandObj:(NSString*)objId atText:(NSString*)text outBlock:(void(^)(NSMutableDictionary *linkDic))outBlock{
    if (!STRISOK(objId)) return;
    NSMutableDictionary *valueDic = nil;
    //1,是否已被理解
    if ([TextStore getSingleWordWithObjId:[STRTOOK(objId) integerValue]]) {
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
                [valueDic setObject:linkArr[0] forKey:objId];
            }
        }
    }
    //5,返回数据;
    if (outBlock) {
        outBlock (valueDic);
    }
}

//MARK:----------找do的对应Text----------
-(void) understandDo:(NSString*)doId atText:(NSString*)text outBlock:(void(^)(NSMutableDictionary *linkDic))outBlock{
    if (!STRISOK(doId)) return;
    NSMutableDictionary *valueDic = nil;
    //1,是否已被理解
    NSArray *localWordArr = [TextStore getWordArrWithDoId:[STRTOOK(doId) integerValue]];
    if (ARRISOK(localWordArr)) {
        for (TextModel *localModel in localWordArr) {
            if ([STRTOOK(text) containsString:localModel.text]) {
                //已理解,并且对应词当前句子也有时,返回;(支持多义词)
                return;
                //改变数据结构;添加计数;(以后习惯系统加)
            }
        }
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
        if (![TextStore getSingleWordWithText:checkWord]) {
            NSArray *findWordFromMem = [[SMG sharedInstance].store searchMemStoreContainerText:checkWord limit:3];
            if (findWordFromMem && findWordFromMem.count >= 3) {//只有达到三次听到的词;才认为是一个词;
                [mArr addObject:checkWord];
            }
        }
    }
    return mArr;
}










@end












