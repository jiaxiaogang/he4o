//
//  AIHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"
#import "AIString.h"
#import "AIChar.h"
#import "AIArray.h"

#import "AILaw.h"
#import "AILogic.h"
#import "AIValue.h"

#import "AIDo.h"
#import "AIObj.h"

#import "AIPointer.h"
#import "AILine.h"
#import "AILineStrong.h"
#import "AILineDampingStrategy.h"


/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define AISTRISOK(a) (a  && [a isKindOfClass:[AIString class]] && a.content && [a.content isKindOfClass:[NSArray class]] && a.content.count > 0)
#define AISTRTOOK(a) (a  && [a isKindOfClass:[AIString class]] ? a : [AIString initWithContent:@""])

//Array
#define AIARRISOK(a) (a  && [a isKindOfClass:[AIArray class]] && a.content && [a.content isKindOfClass:[NSArray class]] && a.content.count > 0)
#define AIARRTOOK(a) (a  && [a isKindOfClass:[AIArray class]]) ?  a : [AIArray initWithObjects:nil]
#define AIARR_INDEX(a,i) (a && [a isKindOfClass:[AIArray class]]) ?  [a objectAtIndex:i] : nil//数组取子防闪



/**
 *  MARK:--------------------快捷建对象--------------------
 */
//Char
#define AIMakeCharByStr(a) [AIChar initWithContentByString:a]
#define AIMakeChar(a) [AIChar initWithContent:a]

//String
#define AIMakeStr(a) [AIString initWithContent:a]
#define AISTRFORMAT(a, ...) [AIString initWithContent:[NSString stringWithFormat:a, ##__VA_ARGS__]]

//Array
#define AIMakeArr(a, ...) [AIArray initWithObjects:a, ##__VA_ARGS__,nil]

//Law
#define AIMakeLaw(a, ...) [AILaw initWithObjects:a, ##__VA_ARGS__,nil]
#define AIMakeLawByArr(arr) [AILaw initWithArray:arr]
#define AIMakeLawByAIArr(arr) [AILaw initWithAIArray:arr]







