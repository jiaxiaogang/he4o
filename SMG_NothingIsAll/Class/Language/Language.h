//
//  LanguageUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------语言组织功能--------------------
 *  1,可到知识图谱中,记忆中查分词;
 *  2,不断提升Language对语言中的行为分解能力;
 *  3,不断提升Language对语言中的理解分析能力;
 *  4,不断提升Language对语言的组织输出能力;
 */
@interface Language : NSObject


//MARK:----------语言输出能力----------
//不理解的不回答;
-(NSString*) outputTextWithRequestText:(NSString*)requestText withStoreModel:(id)storeModel;


/**
 *  MARK:--------------------用于分析语言输入,并且找出规律词和图谱词并返回--------------------
 *
 */
-(NSArray*) inputTextWithRequestText:(NSString*)requestText;





/**
 *  MARK:--------------------给句子智能分词--------------------
 *
 *  (一个句子有可能有多种分法:[[indexPath0,indexPath1],[indexP0]],现在只作一种)
 *
 */
-(NSMutableArray*) getIntelligenceWordArrWithSentence:(NSString*)sentence;



/**
 *  MARK:--------------------从句子中找出所有分词--------------------
 */
-(NSMutableArray*) getWordArrWithSentence:(NSString*)sentence;



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
-(void) getInferenceWord:(NSString*)str withLimit:(NSInteger)limit withHavThan:(NSInteger)havThan withOutBlock:(void(^)(NSMutableArray *valueWords,BOOL havThan))outBlock;


/**
 *  MARK:--------------------addWord--------------------
 *  (DIC | Key:word Value:str | Key:MKObjId Value:NSInteger )
 */
-(void) addWord:(NSDictionary*)word;




@end
