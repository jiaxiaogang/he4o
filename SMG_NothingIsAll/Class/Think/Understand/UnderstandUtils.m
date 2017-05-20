//
//  UnderstandUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "UnderstandUtils.h"
#import "SMGHeader.h"
#import "StoreHeader.h"
#import "FeelHeader.h"
#import "NSString+Extension.h"

@implementation UnderstandUtils




/**
 *  MARK:--------------------从text中找出生分词和已有分词--------------------
 */
+(void) getWordArrAtText:(NSString*)text forceWordArr:(NSArray*)forceWordArr outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr ,NSInteger unknownCount))outBlock{
    //计算机器械;(5字4词)
    //是什么;(3字2词)(其中'是'为单字词)
    //要我说;(3字3词)单字词
    //目前只写双字词
    
    //1,数据
    if (!STRISOK(text)) {
        if (outBlock) {
            outBlock(nil,nil,0);
        }
        return;
    }
    text = STRTOOK(text);
    NSMutableArray *oldArr = [[NSMutableArray alloc] init];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    NSInteger unknownCount = 0;
    //2,forceWordArr->forceRangeArr
    NSMutableArray *forceRangeArr = [[NSMutableArray alloc]init];
    if (ARRISOK(forceWordArr)) {
        for (NSString *word in forceWordArr) {
            NSMutableArray *rangeArr = [text rangeArrOfString:word];
            [forceRangeArr addObjectsFromArray:rangeArr];
        }
    }
    
    //2,循环找text中的新词(支持多字词分析)
    NSInteger curIndex = 0;//解析到的下标
    while (curIndex < text.length) {
        //2.1,数据
        NSString *checkStr = [text substringFromIndex:curIndex];//找词字符串
        NSInteger maxWordLength = MIN(4, checkStr.length);     //词最长10个字
        //2.2,到forceWord找词;
        SMGRange *findForceWord = nil;//距离10之内的SMGRange
        for (SMGRange *range in forceRangeArr) {
            NSInteger distance = range.location - curIndex;
            if (distance >= 0 && distance <= maxWordLength) {
                if (findForceWord == nil) {
                    findForceWord = range;
                }else if(findForceWord.location > range.location) {
                    findForceWord = range;
                }
            }
        }
        //2.3,找到时,如果正好是forceWord,则break;  如果不是,则打断maxWordLength长度;
        if (findForceWord) {
            if (findForceWord.location == curIndex) {
                curIndex += findForceWord.location + findForceWord.length;
                break;
            }else if(findForceWord.location > curIndex){
                maxWordLength = MIN(maxWordLength, findForceWord.location - curIndex);
            }
        }
        
        //2.4,到MKWord里找词;
        BOOL findWord = false;
        for (NSInteger i = maxWordLength; i > 0; i--) {
            NSString *checkWord = [checkStr substringToIndex:i];
            NSDictionary *findLocalWord = [TextStore getSingleWordWithText:checkWord];
            if (findLocalWord) {//是旧词
                [oldArr addObject:findLocalWord];
                findWord = true;
            }else{//不是旧词
                NSInteger sumNone = 0;//有0边是词,需要10次;
                NSInteger sumOne = 0;//有1边是词,需要6次;
                NSInteger sumTwo = 0;//有2边是词,需要3次;
                NSInteger sumAll = 0;//全句都是词时,可分析是否为词,是词时直接1次即可;如:小花吃饭了,(小花是局部名词)
                
                NSArray *allMem = [[SMG sharedInstance].store.memStore getMemoryWithWhereDic:nil];
                for (NSDictionary *itemMem in allMem) {
                    NSString *memText = [itemMem objectForKey:@"text"];
                    if ([SMGUtils compareItemA:memText containsItemB:checkWord]) {
                        //1,找词位置
                        NSRange range = [memText rangeOfString:checkWord];
                        //2,左右撞击边缘
                        BOOL hitLeft = (range.location <= 0 || [self checkLeftInsideIsWordWithText:memText index:range.location]);
                        BOOL hitRight = (range.location + range.length >= memText.length || [self checkRightInsideIsWordWithText:memText index:range.location + range.length]);
                        //3,累计词频
                        if (hitLeft && hitRight) sumTwo ++;
                        if (hitLeft || hitRight) sumOne ++;
                        sumNone ++;
                        //4,判断结果
                        if (sumNone >= 10 || sumOne >= 6 || sumTwo >= 3) {
                            findWord = true;
                            [newArr addObject:checkWord];
                            break;
                        }
                    }
                }
            }
            if (findWord) {//发现词,则退出循环;下标加i;
                curIndex += i;
                break;
            }
        }
        if (!findWord) {
            curIndex ++;//未发现词,则下标加1;
            unknownCount ++;
        }
    }
    //3,返回数据
    if (outBlock) {
        outBlock(oldArr,newArr,unknownCount);
    }

}


/**
 *  MARK:--------------------从'记忆'中找到需要'理解'处理的数据--------------------
 *  value:中的元素数据格式:{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}
 */
+(NSMutableArray*) getNeedUnderstandMemoryWithObjId:(NSString*)objId{
    if (STRISOK(objId)) {
        //2,取相关记忆
        NSDictionary *where = [NSDictionary dictionaryWithObjectsAndKeys:@[objId],@"obj", nil];
        NSMutableArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWhereDic:where limit:NSIntegerMax];
        return [self getNeedUnderstandMemoryWithMemArr:memArr];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithDoId:(NSString*)doId{
    if (STRISOK(doId)) {
        //2,取相关记忆
        NSMutableArray *memArr = [[SMG sharedInstance].store.memStore getMemoryContainsWithDoId:doId limit:10];
        return [self getNeedUnderstandMemoryWithMemArr:memArr];
    }
    return nil;
}

+(NSMutableArray*) getNeedUnderstandMemoryWithMemArr:(NSMutableArray*)memArr{
    if (!ARRISOK(memArr)) {
        return nil;
    }
    //1,申请收集数据的数组
    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
    //2,收集数据
    for (NSDictionary *memItem in memArr) {
        //3,每条记忆都收集unknownData;
        __block NSMutableArray *unknownWordArr = [[NSMutableArray alloc] init];
        NSMutableArray *unknownObjArr = [[NSMutableArray alloc] init];
        NSMutableArray *unknownDoArr = [[NSMutableArray alloc] init];
        //memItem结构:{do=[feelDoModel],obj=[10,12],text=@"asdf"}
        //条件1,取未理解元素和;不能>3
        if ([memItem objectForKey:@"obj"]) {
            for (NSString *objId in [memItem objectForKey:@"obj"]) {
                if(![TextStore getSingleWordWithObjId:[STRTOOK(objId) intValue]]){
                    [unknownObjArr addObject:objId];
                }
            }
        }
        if ([memItem objectForKey:@"do"]) {
            for (NSDictionary *item in [memItem objectForKey:@"do"]) {
                NSString *doId = STRTOOK([item objectForKey:@"doId"]);
                if(![TextStore getSingleWordWithDoId:[doId integerValue]]) {
                    [unknownDoArr addObject:[item objectForKey:@"doId"]];
                }
            }
        }
        if (unknownDoArr.count + unknownObjArr.count <= 3) {
            //条件2,不能有未分词的陌生词;
            [UnderstandUtils getWordArrAtText:[memItem objectForKey:@"text"] forceWordArr:nil outBlock:^(NSArray *oldWordArr, NSArray *newWordArr,NSInteger unknownCount) {
                [TextStore addWordWithTextArr:newWordArr];//存新词;
                if (!ARRISOK(newWordArr) && unknownCount == 0) {
                    for (TextModel *oldModel in oldWordArr) {
                        NSInteger objId = [LawStore searchSingle_OtherIdWithClass:TextModel.class withClassId:oldModel.rowid otherClass:ObjModel.class];
                        NSInteger doId = [LawStore searchSingle_OtherIdWithClass:TextModel.class withClassId:oldModel.rowid otherClass:DoModel.class];
                        if (objId == 0 && doId == 0) {
                            [unknownWordArr addObject:oldModel];
                        }
                    }
                    //条件3,未理解的分词数量差<2;
                    NSInteger diffCount = unknownWordArr.count - unknownDoArr.count - unknownObjArr.count;
                    if (diffCount < 2 && diffCount > -2) {//xxx当"小赤吃苹果"中"苹果"为已知词时,"obj小赤"和"do吃"与"word小赤吃苹果"对应上了;导致把"小赤吃苹果"理解为"吃";
                        //如:"text一手机器"对应"obj手机"时;"一手机器"依然是在描述"手机"不过并不是"手机"的名称;
                        NSDictionary *valueItem = [NSDictionary dictionaryWithObjectsAndKeys:unknownObjArr,@"unknowObjArr",unknownDoArr,@"unknowDoArr",unknownWordArr,@"unknowWordArr",nil];
                        [valueArr addObject:valueItem];
                    }
                }
            }];
        }
    }
    return valueArr;//此处;每条记忆都找到有效数据;
}


/**
 *  MARK:--------------------private--------------------
 */
//检测Index左侧是否为词
+(BOOL) checkLeftInsideIsWordWithText:(NSString*)text index:(NSInteger)index{
    text = STRTOOK(text);
    //1,左侧没字了,不是词 | index越界了,不是词
    if (index <= 0 || index > text.length) {
        return false;
    }
    //2,检查最长7个字范围是不是词
    NSInteger maxLength = MIN(index, 7);
    for (NSInteger i = 1; i <= maxLength; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(index - i, i)];
        if ([TextStore getSingleWordWithText:checkWord]) {
            return true;
        }
    }
    return false;
}

//检测Index右侧是否为词
+(BOOL) checkRightInsideIsWordWithText:(NSString*)text index:(NSInteger)index{
    text = STRTOOK(text);
    //1,左侧没字了,不是词 | index越界了,不是词
    if (index >= text.length || index < 0) {
        return false;
    }
    //2,检查最长7个字范围是不是词
    NSInteger maxLength = MIN(text.length - index, 7);
    for (NSInteger i = 1; i <= maxLength; i++) {
        NSString *checkWord = [text substringWithRange:NSMakeRange(index, i)];
        if ([TextStore getSingleWordWithText:checkWord]) {
            return true;
        }
    }
    return false;
}






/**
 *  MARK:--------------------预判词--------------------
 *  参数:
 *      1,limit:取几个
 *      2,havThan:有没达到多少个结果
 *
 *  注:
 *      1,目前仅支持用"一刀两"推出"一刀两断"从前至后预判;
 *      2,词本身不作数 如:"计算" 只能判出"计算机"不能返回"计算";
 */
-(void) getInferenceWord:(NSString*)str withLimit:(NSInteger)limit withHavThan:(NSInteger)havThan withOutBlock:(void(^)(NSMutableArray *valueWords,BOOL havThan))outBlock {
    //数据检查
    NSMutableArray *wordArr = [TextStore getWordArr];
    NSMutableArray *mArr = nil;
    str = STRTOOK(str);
    if (!STRISOK(str) || limit == 0 || wordArr == nil) {
        if (outBlock) outBlock(mArr,havThan >= 0);
    }
    //找
    NSInteger findCount = 0;
    for (NSInteger i = wordArr.count - 1; i >= 0; i--) {
        NSDictionary *item = wordArr[i];
        NSString *itemText = [item objectForKey:@"text"];
        if (itemText && itemText.length > str.length) {
            if ([str isEqualToString:[itemText substringToIndex:str.length]]) {
                if (mArr == nil) {
                    mArr = [[NSMutableArray alloc] init];
                }
                //收集;
                if (mArr.count < limit) {
                    [mArr addObject:itemText];
                }
                //计数;
                findCount ++;
                //收集完毕;
                if (findCount >= havThan && mArr.count >= limit) {
                    break;
                }
            }
        }
    }
    //送出
    if (outBlock) outBlock(mArr,findCount >= havThan);
}


@end
