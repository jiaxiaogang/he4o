//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AIPointer,AIKVPointer,AIObject,AIArray,ThinkModel,AIPort,AINodeBase;
@interface SMGUtils : NSObject


//MARK:===============================================================
//MARK:                     < PointerId >
//MARK:===============================================================
+(NSInteger) createPointerId:(NSString*)algsType dataSource:(NSString*)dataSource;
+(NSInteger) createPointerId:(BOOL)updateLastId algsType:(NSString*)algsType dataSource:(NSString*)dataSource;
+(NSInteger) getLastNetNodePointerId:(NSString*)algsType dataSource:(NSString*)dataSource;
+(void) setNetNodePointerId:(NSInteger)count algsType:(NSString*)algsType dataSource:(NSString*)dataSource;

//MARK:===============================================================
//MARK:                     < AIPointer >
//MARK:===============================================================
//General指针
+(AIKVPointer*) createPointer:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem;

//Direction的mv分区pointer;(存引用序列)
+(AIKVPointer*) createPointerForDirection:(NSString*)mvAlgsType direction:(MVDirection)direction;

//生成小脑CanOut指针;
+(AIKVPointer*) createPointerForCerebelCanOut;

//生成indexValue的指针;
+(AIKVPointer*) createPointerForValue:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut;
+(AIKVPointer*) createPointerForValue:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut;

//索引指针
+(AIKVPointer*) createPointerForIndex;

//微信息值指针
+(AIKVPointer*) createPointerForData:(NSString*)algsType dataSource:(NSString*)dataSource;

/**
 *  MARK:--------------------概念节点指针--------------------
 *  @param dataSource : 有三种情况;
 *      1. input输入TIR新概念时,概念的ds就是算法的at,比如:AIVersionAgls;
 *      2. 类比构建器时,概念的ds就是类比源,比如:有无大小同异;
 *      3. 默认(其它)时,概念节点的ds是其content_ps中稀疏码共同的at;
 */
+(AIKVPointer*) createPointerForAlg:(NSString*)folderName dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem;

/**
 *  MARK:--------------------时序节点指针--------------------
 *  @param ds : 有两种情况;
 *      1. 类比构建器时,时序的ds就是类比源,比如:有无大小同异;
 *      2. 默认(其它)时,时序节点的ds=DefaultDataSource;
 */
+(AIKVPointer*) createPointerForFo:(NSString*)folderName ds:(NSString*)ds;

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Compare) >
//MARK:===============================================================
@interface SMGUtils (Compare)

//+(BOOL) compareItemA:(id)itemA itemB:(id)itemB;
//+(BOOL) compareArrayA:(NSArray*)arrA arrayB:(NSArray*)arrB;
//+(BOOL) compareItemA:(id)itemA containsItemB:(id)itemB;
//+(NSComparisonResult) compareRefsA_p:(NSArray*)refsA_p refsB_p:(NSArray*)refsB_p;//比较refsA是否比refsB大


//比较pA是否比pB大 (1级pId,2级identifier)
+(NSComparisonResult) comparePointerA:(AIPointer*)pA pointerB:(AIPointer*)pB;

//类比port (1级强度,2级pointer)
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


/**
 *  MARK:--------------------searchObj--------------------
 */
+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName;
+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName time:(double)time;//找到后,缓存到redis,time秒;
+(id) searchObjectForFilePath:(NSString*)filePath fileName:(NSString*)fileName time:(double)time;


/**
 *  MARK:--------------------insertObj--------------------
 */
//+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName;
+(void) insertObject:(NSObject*)obj pointer:(AIPointer*)pointer fileName:(NSString*)fileName time:(double)time;
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time saveDB:(BOOL)saveDB;//同时插入到redis,time秒


/**
 *  MARK:--------------------Node--------------------
 */
+(id) searchNode:(AIPointer*)pointer;
+(NSArray*) searchNodes:(NSArray*)ps;
+(void) insertNode:(AINodeBase*)node;

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
+(BOOL) containsSub_p:(AIPointer*)sub_p parentPorts:(NSArray*)parentPorts;

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (convert) >
//MARK:===============================================================
@interface SMGUtils (Convert)

/**
 *  MARK:--------------------将ports端口中指向转换为指针数组返回--------------------
 *  @result notnull
 */
+(NSMutableArray*) convertPointersFromPorts:(NSArray*)ports;

//将pointers转字符串;
+(NSString*) convertPointers2String:(NSArray*)pointers;

//将概念中的value_ps(含嵌套)展开成纯微信息的组; @result : notnull
+(NSMutableArray*) convertValuePs2MicroValuePs:(NSArray*)value_ps;

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Sort) >
//MARK:===============================================================
@interface SMGUtils (Sort)

//对ps进行从大到小的排序
+(NSArray*) sortPointers:(NSArray*)ps;

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Remove) >
//MARK:===============================================================
@interface SMGUtils (Remove)

/**
 *  MARK:--------------------取差集--------------------
 *  @result notnull
 */
+(NSMutableArray*) removeSub_ps:(NSArray*)sub_ps parent_ps:(NSArray*)parent_ps;
+(NSMutableArray*) removeSub_p:(AIPointer*)sub_p parent_ps:(NSArray*)parent_ps;

/**
 *  MARK:--------------------防重--------------------
 *  @result notnull
 */
+(NSMutableArray*) removeRepeat:(NSArray*)protoArr;

/**
 *  MARK:--------------------取交集--------------------
 *  @result notnull
 */
+(NSArray*) filterSame_ps:(NSArray*)a_ps parent_ps:(NSArray*)b_ps;
//从bps中,找到与ap同区的bItem返回;
+(AIKVPointer*) filterSameIdentifier_p:(AIKVPointer*)a_p b_ps:(NSArray*)b_ps;
//从bps中,找到与aps同区的 所有映射结果 返回;
+(NSMutableDictionary*) filterSameIdentifier_ps:(NSArray*)a_ps b_ps:(NSArray*)b_ps;
//从b_ps中,找出与a_p同区不同值的指针;
+(AIKVPointer*) filterSameIdentifier_DiffId_p:(AIKVPointer*)a_p b_ps:(NSArray*)b_ps;
//同区不同值
+(NSMutableDictionary*) filterSameIdentifier_DiffId_ps:(NSArray*)a_ps b_ps:(NSArray*)b_ps;

/**
 *  MARK:--------------------从from_ps中,筛选出有效的元素返回--------------------
 *  @result notnull
 */
+(NSArray*) filterPointers:(NSArray *)from_ps checkValid:(BOOL(^)(AIKVPointer *item_p))checkValid;

/**
 *  MARK:--------------------从a_ps和b_ps中,筛选出有效的元素映射返回--------------------
 *  @result notnull (返回的字典中key,为NSData类型)
 */
+(NSMutableDictionary*) filterPointers:(NSArray *)a_ps b_ps:(NSArray*)b_ps checkItemValid:(BOOL(^)(AIKVPointer *a_p,AIKVPointer *b_p))checkItemValid;

/**
 *  MARK:--------------------筛选数组--------------------
 *  @result notnull
 */
+(NSMutableArray*) filterArr:(NSArray *)arr checkValid:(BOOL(^)(id item))checkValid;
+(NSMutableArray*) filterArr:(NSArray *)arr checkValid:(BOOL(^)(id item))checkValid limit:(NSInteger)limit;

/**
 *  MARK:--------------------用analogyType来筛选ports--------------------
 *  @result notnull
 */
+(NSArray*) filterPorts_Normal:(NSArray*)ports;
+(NSArray*) filterPorts:(NSArray*)ports havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes;

/**
 *  MARK:--------------------查找单条--------------------
 */
+(id) filterSingleFromArr:(NSArray *)arr checkValid:(BOOL(^)(id item))checkValid;

@end

//MARK:===============================================================
//MARK:                     < SMGUtils (Collect) >
//MARK:===============================================================
@interface SMGUtils (Collect)

/**
 *  MARK:--------------------并集--------------------
 *  @result notnull
 */
+(NSMutableArray *) collectArrA:(NSArray*)arrA arrB:(NSArray*)arrB;
+(NSMutableArray *) collectArrA_NoRepeat:(NSArray*)arrA arrB:(NSArray*)arrB;

@end
