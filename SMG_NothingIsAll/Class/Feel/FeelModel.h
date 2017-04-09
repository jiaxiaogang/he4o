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



/**
 *  MARK:--------------------先天attributesKeys--------------------
 */
static NSString *AttributesKey_Position     = @"position";  //方位(value:x,y,z)(对应行为:看)
static NSString *AttributesKey_Color        = @"color";     //颜色值(value:FFFFFF)(对应行为:看)
static NSString *AttributesKey_Pain         = @"pain";      //痛感(value:-1->1)(对应行为:摸打)
static NSString *AttributesKey_Hungry       = @"hungry";    //饿感(value:-1->1)(对应行为:饱饿)
static NSString *AttributesKey_Bright       = @"bright";    //亮度(value:0->1)(对应行为:看)
static NSString *AttributesKey_Shape        = @"shape";     //外形(value:path和size)(对应行为:看)
static NSString *AttributesKey_Size         = @"size";      //大小(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_SizeHeight   = @"sizeHeight";//高度(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_SizeWidth    = @"sizeWidth"; //宽窄(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_SizeLong     = @"sizeLong";  //长短(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_SizeThick    = @"sizeThick"; //粗细(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_SizeDeep     = @"sizeDeep";  //深浅(value:FeelValueModel)(对应行为:比)









