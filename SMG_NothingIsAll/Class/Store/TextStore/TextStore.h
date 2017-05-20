//
//  Text.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------字符串处理能力--------------------
 *  注:
 *      计算机
 *      1,"字符串处理能力"是使用"字符串描述现实"的后天能力;(因计算机先天懂字符串,所以应该将字符串贴合回现实世界)
 *      
 *      人类:
 *      1,"文字语言能力"是使用"图像描述现实"的后天能力;(文字是图形)
 *      2,"语音语言能力"是使用"声音描述现实"的后天能力;
 *
 *
 *  1,可到知识图谱中,记忆中查分词;
 *  2,不断提升Language对语言中的行为分解能力;
 *  3,不断提升Language对语言中的理解分析能力;
 *  4,不断提升Language对语言的组织输出能力;
 *  
 */
@class TextModel;
@interface TextStore : NSObject

//精确匹配某词
+(TextModel*) getSingleWordWithText:(NSString*)text;
+(TextModel*) getSingleWordWithItemId:(NSInteger)itemId;
+(TextModel*) getSingleWordWithObjId:(NSInteger)objId;
+(TextModel*) getSingleWordWithDoId:(NSInteger)doId;

//获取多条
+(NSMutableArray*) getWordArrWithText:(NSString*)text;
+(NSMutableArray*) getWordArrWithObjId:(NSInteger)objId;
+(NSMutableArray*) getWordArrWithDoId:(NSInteger)doId;
+(NSMutableArray*) getWordArr;

/**
 *  MARK:--------------------addWord--------------------

 */
+(TextModel*) addWord:(NSString*)text;
-(NSMutableArray*) addWordArr:(NSArray*)wordArr;
-(NSDictionary*) addWord:(NSString*)word withObjId:(NSString*)objId withDoId:(NSString*)doId;


-(void) clear;

@end



