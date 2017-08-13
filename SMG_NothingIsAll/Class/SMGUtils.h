//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIPointer;
@interface SMGUtils : NSObject

/**
 *  MARK:--------------------联想AILine点亮区域--------------------
 *  layerCount,节点层数;(0->自己)(1->自己和自己的抽象层)(2->自已,自己的抽象层,抽象层的其它实例,抽象层的抽象层)(>2:以此类推)
 */
+(NSMutableArray*) lightArea_1:(AIPointer*)lightPointer;
+(NSMutableArray*) lightArea_2:(AIPointer*)lightPointer;
+(NSMutableArray*) lightArea_3:(AIPointer*)lightPointer;
+(NSMutableArray*) lightArea:(AIPointer*)lightPointer layerCount:(NSInteger)layerCount;

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



/**
 *  MARK:--------------------属性算法-Text--------------------
 */
@interface FeelTextUtils : NSObject

+(NSInteger) getLength:(NSString*)text;

@end


@interface TextStoreUtils : NSObject

/**
 *  MARK:--------------------获取句子中未知词数--------------------
 *
 *  参数:
 *      1,knowRangeArr: 扫描到的所有词
 *      2,fromIndex:    从哪里开始扫描(正反双向都扫)
 *      3,sentence:     句子
 *
 *  返回值:NSNumber数组
 *  注:这种算法式的理解,应该费弃;(语言功能是后天自主学习而来;先天算法局限性太大)
 *
 */
//+(NSArray*) getUnknownWordCount:(NSArray*)knowRangeArr fromIndex:(NSInteger)fromIndex withSentence:(NSString*)sentence;


@end


/**
 *  MARK:--------------------MindValue算法集--------------------
 */
@class AIHungerLevelChangedModel,AIMindValueModel,AIHungerStateChangedModel;
@interface MindValueUtils : NSObject

+(AIMindValueModel*) getMindValue_HungerLevelChanged:(AIHungerLevelChangedModel*)model;
//+(AIMindValueModel*) getMindValue_HungerStateChanged:(AIHungerStateChangedModel*)model;

@end
