//
//  SMGUtil+General.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/9.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "SMGUtils.h"

#define kHHmmss @"HH:mm:ss"
#define kHHmmssSSS @"HH:mm:ss:SSS"
#define kyyyyMMddHHmmssSSS @"yyyy-MM-dd HH:mm:ss:SSS"
#define kyyyyMMddHHmmssSSS_Simple @"yyyyMMddHHmmssSSS"

@interface SMGUtils (General)

//string
+(BOOL) strIsOk:(NSString*)s;
+(NSString*) strToOk:(NSString*)s;
+(NSArray*) strToArr:(NSString*)str sep:(NSString*)sep;     //str分隔arr
+(NSString*) subStr:(NSString*)s toIndex:(NSInteger)index;
+(NSString*) codeLocateFormat:(NSString*)fileName line:(NSInteger)line;

//array
+(BOOL) arrIsOk:(NSArray*)a;                            //数组有效判断
+(NSArray*) arrToOk:(NSArray*)a;                        //数组防闪
+(id) arrIndex:(NSArray*)a index:(NSInteger)i;          //取数组index元素
+(id) arrTransIndex:(NSArray*)a index:(NSInteger)i;     //取数组反序index元素
+(BOOL) arrIndexIsOk:(NSArray*)a index:(NSInteger)i;    //数组index有效判断
+(NSArray*) arrSub:(NSArray*)a start:(NSInteger)s length:(NSInteger)l;

//number
+(BOOL) numIsOk:(NSNumber*)n;
+(NSNumber*) numToOk:(NSNumber*)n;

//dictionary
+(BOOL) dicIsOk:(NSDictionary*)d;
+(NSDictionary*) dicToOk:(NSDictionary*)d;

//pointer
+(BOOL) pointerIsOk:(AIPointer*)p;

//object
+(BOOL) isOk:(NSObject*)o class:(Class)c;

//date2Str (性能说明: stringFromDate较慢,所以批量处理时建议使用异步);
+(NSString*) date2HHMMSS;
+(NSString*) date2HHMMSSSSS;
+(NSString*) date2yyyyMMddHHmmssSSS:(NSDate*)date;
+(NSString*) date2Str:(NSString*)format date:(NSDate*)date;

//dateFromStr
+(NSDate*) dateFromTimeStr_yyyyMMddHHmmssSSS:(NSString*)timeStr;
+(NSDate*) dateFromTimeStr:(NSString*)timeStr format:(NSString*)format;

//timestampFromStr
+(long long)timestampFromStr_yyyyMMddHHmmssSSS:(NSString*)timeStr defaultResult:(long long)defaultResult;

@end
