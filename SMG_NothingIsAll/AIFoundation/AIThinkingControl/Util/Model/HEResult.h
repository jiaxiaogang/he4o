//
//  HEResult.h
//  SMG_NothingIsAll
//
//  Created by jia on 04.09.2024.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEResult : NSObject

+(HEResult*) newFailure;
+(HEResult*) newSuccess;

@property (strong, nonatomic) NSMutableDictionary *dic;//用于存所有返回数据为dic;

-(HEResult*) mk:(NSString*)k v:(id)v;
-(id) get:(NSString*)k;

//MARK:===============================================================
//MARK:                     < 方便方法 >
//MARK:===============================================================

-(HEResult*) mkIsNew:(BOOL)isNew;
-(HEResult*) mkData:(id)data;
-(BOOL) success;
-(BOOL) isNew;
-(id) data;

-(HEResult*) mkSPScore:(CGFloat)spScore;
-(CGFloat) spScore;
-(HEResult*) mkPStrong:(NSInteger)value;
-(CGFloat) pStrong;

@end
