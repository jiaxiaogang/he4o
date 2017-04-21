//
//  SMGHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGEnum.h"
#import "SMG.h"
#import "SMGUtils.h"
#import "SMGRange.h"



/**
 *  MARK:--------------------数据检查--------------------
 */

//是否空字符串
#define STRISOK(a) (a  && ![a isKindOfClass:[NSNull class]] && [a isKindOfClass:[NSString class]] && ![a isEqualToString:@""])

//字符串防闪
#define STRTOOK(a) (a  && ![a isKindOfClass:[NSNull class]]) ? ([a isKindOfClass:[NSString class]] ? a : [NSString stringWithFormat:@"%@", a]) : @""

//数组防闪
#define ARRTOOK(a) (a  && [a isKindOfClass:[NSArray class]]) ?  a : [NSArray new]

//数组取子防闪
#define ARR_INDEX(a,i) (a && [a isKindOfClass:[NSArray class]] && a.count > i) ?  a[i] : nil



/**
 *  MARK:--------------------快捷建对象--------------------
 */

//SMGRange
#define SMGRangeMake(loc,len) [SMGRange rangeWithLocation:loc length:len]
