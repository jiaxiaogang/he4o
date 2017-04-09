//
//  FeelModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------感觉码 模型--------------------
 */
@class FeelValueModel;
@interface FeelModel : NSObject

@property (assign, nonatomic) NSInteger feelId;
@property (strong,nonatomic) NSMutableDictionary *attributes;   //可自由增减的属性池;

/**
 *  MARK:--------------------追加属性--------------------
 *  feelValueModel:比较值
 *  key:比的是什么;(key来自tmcache存的"FeelModel_Attributes_Keys")
 */
-(void) appendFeelValueModel:(FeelValueModel*)feelValueModel withKEY:(NSString*)key;    //追加属性;






/**
 *  MARK:--------------------propertys--------------------
 */
//MARK:----------追加属性key----------
-(void) addAttributesKey:(NSString*)key;

@end
