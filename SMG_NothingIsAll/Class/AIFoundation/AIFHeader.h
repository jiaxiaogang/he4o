//
//  AIFHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFObject.h"
#import "AIFString.h"
#import "AIFChar.h"
#import "AIFArray.h"


/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define AIFSTRISOK(a) (a  && [a isKindOfClass:[AIFString class]] && a.content && [a.content isKindOfClass:[NSArray class]] && a.content.count > 0)
#define AIFSTRTOOK(a) (a  && [a isKindOfClass:[AIFString class]] ? a : [AIFString initWithContent:@""])
#define AIFSTRFORMAT(a, ...) [AIFString initWithContent:[NSString stringWithFormat:a, ##__VA_ARGS__]]

//Array
#define AIFARRISOK(a) (a  && [a isKindOfClass:[AIFArray class]] && a.content && [a.content isKindOfClass:[NSArray class]] && a.content.count > 0)
#define AIFARRTOOK(a) (a  && [a isKindOfClass:[AIFArray class]]) ?  a : [AIFArray initWithObjects:nil]
#define AIFARR_INDEX(a,i) (a && [a isKindOfClass:[AIFArray class]]) ?  [a objectAtIndex:i] : nil//数组取子防闪
#define AIFARRFORMAT(a, ...) [AIFArray initWithObjects:a, ##__VA_ARGS__]



/**
 *  MARK:--------------------快捷建对象--------------------
 */










