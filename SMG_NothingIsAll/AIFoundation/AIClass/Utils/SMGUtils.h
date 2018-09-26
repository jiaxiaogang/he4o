//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AIPointer,AIKVPointer,AIObject,AIArray,AILine,ThinkModel,AIPort;
@interface SMGUtils : NSObject


//MARK:===============================================================
//MARK:                     < AIPointer & PointerId >
//MARK:===============================================================
+(NSInteger) createPointerId:(NSString*)algsType dataSource:(NSString*)dataSource;
+(NSInteger) createPointerId:(BOOL)updateLastId algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
+(NSInteger) getLastNetNodePointerId:(NSString*)algsType dataSource:(NSString*)dataSource;
+(void) setNetNodePointerId:(NSInteger)count algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
+(AIKVPointer*) createPointerForNode:(NSString*)folderName;
+(AIKVPointer*) createPointer:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
+(AIKVPointer*) createPointerForAbsValue:(NSString*)key;//AbsValue地址,key作为dataSource;
+(AIKVPointer*) createPointerForAbsValue:(NSString*)key pointerId:(NSInteger)pointerId;//AbsValue地址 & key作为dataSource; & 指定pointerId

//Direction的mv分区pointer;(存引用序列)
+(AIKVPointer*) createPointerForDirection:(NSString*)mvAlgsType direction:(MVDirection)direction;

//outputReference的"分区算法标识";(存引用序列)
+(AIKVPointer*) createPointerForOutputReference:(NSString*)algsType dataSource:(NSString*)dataSource;

//生成小脑node指针;
+(AIKVPointer*) createPointerForOutputNode:(NSString*)algsType dataSource:(NSString*)dataSource;

//生成小脑索引指针
+(AIKVPointer*) createPointerForOutputValue:(NSString*)algsType dataSource:(NSString*)dataSource;
+(AIKVPointer*) createPointerForOutputValue:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource;

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Compare) >
//MARK:===============================================================
@interface SMGUtils (Compare)

+(BOOL) compareItemA:(id)itemA itemB:(id)itemB;
+(BOOL) compareArrayA:(NSArray*)arrA arrayB:(NSArray*)arrB;
+(BOOL) compareItemA:(id)itemA containsItemB:(id)itemB;
+(NSComparisonResult) comparePointerA:(AIPointer*)pA pointerB:(AIPointer*)pB;
+(NSComparisonResult) compareRefsA_p:(NSArray*)refsA_p refsB_p:(NSArray*)refsB_p;//比较refsA是否比refsB大
+(NSComparisonResult) comparePortA:(AIPort*)pA portB:(AIPort*)pB;
+(NSComparisonResult) compareIntA:(NSInteger)intA intB:(NSInteger)intB;
+(NSComparisonResult) compareFloatA:(CGFloat)floatA floatB:(CGFloat)floatB;

@end


//MARK:===============================================================
//MARK:                     < @SMGUtils (DB) >
//MARK:===============================================================
@interface SMGUtils (DB)
/**
 *  MARK:--------------------SQL语句之rowId--------------------
 */
+(NSString*) sqlWhere_RowId:(NSInteger)rowid;
//+(NSString*) sqlWhere_K:(id)columnName V:(id)value;
//+(NSDictionary*) sqlWhereDic_K:(id)columnName V:(id)value;
+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName;
+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName time:(double)time;//找到后,缓存到redis,time秒;
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName;
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time;//同时插入到redis,time秒

@end


//MARK:===============================================================
//MARK:                     < MathUtils >
//MARK:===============================================================
@interface MathUtils : NSObject

//数据范围变换
+(CGFloat) getNegativeTen2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getZero2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getValueWithOriRange:(UIFloatRange)oriRange targetRange:(UIFloatRange)targetRange oriValue:(CGFloat)oriValue;


@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Contains) >
//MARK:===============================================================
@interface SMGUtils (Contains)

//判断parent_ps是否包含sub_ps;
+(BOOL) containsSub_ps:(NSArray*)sub_ps parent_ps:(NSArray*)parent_ps;
+(BOOL) containsSub_p:(AIPointer*)sub_p parent_ps:(NSArray*)parent_ps;

@end
