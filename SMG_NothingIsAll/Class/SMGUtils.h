//
//  SMGUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIObject;
@interface SMGUtils : NSObject

/**
 *  MARK:--------------------联想AILine点亮区域--------------------
 *  layerCount,节点层数;(0->自己)(1->自己和自己的抽象层)(2->自已,自己的抽象层,抽象层的其它实例,抽象层的抽象层)(>2:以此类推)
 */
+(NSMutableArray*) lightArea_Vertical_1:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_Vertical_2:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel energy:(NSInteger)energy;//使用能量点亮神经网络区域;(依赖AILine的强度)
+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel layerCount:(NSInteger)layerCount;
+(NSMutableArray*) lightArea_Horizontal:(AIObject*)lightModel;
+(NSMutableArray*) lightArea_AILineTypeIsLawWithLightModels:(NSArray*)lightModels;
+(NSMutableArray*) lightArea_LightModels:(NSArray*)lightModels; //区域点亮

/**
 *  MARK:--------------------StoreGroup--------------------
 */
+(void) store_Insert:(AIObject*)obj;//默认insert,并awareness,并postNotice;
+(void) store:(void(^)(void))storeBlock aiLine:(void(^)(void))lineBlock postNotice:(BOOL)postN postObj:(NSArray*)postObj;

/**
 *  MARK:--------------------AILine--------------------
 */
+(CGFloat) aiLine_GetLightEnergy:(CGFloat)strongValue;//点亮某神经元所需要的能量值;strongValue为0-100,返回为1-0;

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
