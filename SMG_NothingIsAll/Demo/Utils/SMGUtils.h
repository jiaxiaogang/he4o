//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIObject,AIArray,AILine,ThinkModel;
@interface SMGUtils : NSObject

//MARK:===============================================================
//MARK:                     < 联想AILine点亮区域 >
//MARK:===============================================================

/**
 *  MARK:--------------------层数点亮--------------------
 *  @param layerCount : 节点层数
 *  (0->自己)(1->自己和自己的抽象层)(2->自已,自己的抽象层,抽象层的其它实例,抽象层的抽象层)(>2:以此类推)
 */
+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel layerCount:(NSInteger)layerCount;

+(NSMutableArray*) lightArea_Vertical_1:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_Vertical_2:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel energy:(NSInteger)energy;//使用能量点亮神经网络区域;(依赖AILine的强度)
+(NSMutableArray*) lightArea_Horizontal:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_AILineTypeIsLawWithLightModels:(NSArray*)lightModels;  //横向点亮实例...
+(void) lightArea_AILineTypeIsLaw:(ThinkModel*)thinkModel;//纵向点亮实例...
+(NSMutableArray*) lightArea_LightModels:(NSArray*)lightModels; //区域点亮


//MARK:===============================================================
//MARK:                     < AILine >
//MARK:===============================================================
+(CGFloat) aiLine_GetLightEnergy:(CGFloat)strongValue;//点亮某神经元所需要的能量值;strongValue为0-100,返回为1-0;


/**
 *  MARK:--------------------生产神经网络--------------------
 *  @param aiObjs : 神经网络连接的AIObject组;
 */
+(AILine*) ailine_CreateLine:(NSArray*)aiObjs type:(AILineType)type;


//MARK:===============================================================
//MARK:                     < AIPointer >
//MARK:===============================================================
+(NSInteger) aiPointer_CreatePointerId;

/**
 *  MARK:--------------------NetNode_PointerId--------------------
 */
//netNode
+(NSInteger) getLastNetNodePointerId;
+(void) setNetNodePointerId:(NSInteger)count;

//netData
+(NSInteger) getLastNetDataPointerId;
+(void) setNetDataPointerId:(NSInteger)count;

@end


/**
 *  MARK:--------------------比较--------------------
 */
@interface SMGUtils (Compare)
+(BOOL) compareItemA:(id)itemA itemB:(id)itemB;
+(BOOL) compareItemA:(id)itemA containsItemB:(id)itemB;
@end



@interface DBUtils : NSObject
/**
 *  MARK:--------------------SQL语句之rowId--------------------
 */
+(NSString*) sqlWhere_RowId:(NSInteger)rowid;
+(NSString*) sqlWhere_K:(id)columnName V:(id)value;
+(NSDictionary*) sqlWhereDic_K:(id)columnName V:(id)value;

@end


@interface MathUtils : NSObject

/**
 *  MARK:--------------------数据范围变换--------------------
 */
+(CGFloat) getNegativeTen2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getZero2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue;
+(CGFloat) getValueWithOriRange:(UIFloatRange)oriRange targetRange:(UIFloatRange)targetRange oriValue:(CGFloat)oriValue;


@end
