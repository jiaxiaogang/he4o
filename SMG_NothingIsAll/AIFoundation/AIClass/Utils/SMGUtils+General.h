//
//  SMGUtil+General.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/9.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "SMGUtils.h"

@interface SMGUtils (General)

//string
+(BOOL) strIsOk:(NSString*)s;
+(NSString*) strToOk:(NSString*)s;
+(NSString*) subStr:(NSString*)s toIndex:(NSInteger)index;

//array
+(BOOL) arrIsOk:(NSArray*)a;
+(NSArray*) arrToOk:(NSArray*)a;
+(id) arrIndex:(NSArray*)a index:(NSInteger)i;
+(BOOL) arrIndexIsOk:(NSArray*)a index:(NSInteger)i;
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

@end
