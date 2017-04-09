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
static NSString *AttributesKey_Temperature  = @"temperature";//温度(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_TasteSweet   = @"tasteSweet"; //甜味(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_TasteSour    = @"tasteSour";  //酸味(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_TasteBitter  = @"tasteBatter";//苦味(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_TastePiquant = @"tastePiquant";//辣味(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_TasteSalty   = @"tasteSalty";//咸味(value:FeelValueModel)(对应行为:比)
static NSString *AttributesKey_Speed        = @"speed";     //速度(value:FeelValueModel)(对应行为:比)
//...多少,力气,硬度,年龄,重量,虚实,胖瘦等;
//(随后把这里精典成size表示一切尺寸,或者直接由比较来表示一切)
//定义越多,实现越少;只有去掉一切定义;保留最原始的数据,才能够









