//
//  AIHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGEnum.h"
#import "SMGUtils.h"
#import "SMGConfig.h"
#import "AINodeBase.h"
#import "AIFoNodeBase.h"
#import "AICMVNodeBase.h"
#import "NVHeader.h"
#import "AIInput.h"

/**
 *  MARK:--------------------PathKey--------------------
 */

//algNode
#define PATH_NET_ALG_NODE           @"NET_ALG_NODE"                         //Alg节点根目录;(白质)
#define PATH_NET_ALG_ABS_NODE       @"NET_ALG_ABS_NODE"                     //AbsAlg节点根目录;(白质)

//foNode
#define PATH_NET_FRONT_ORDER_NODE   @"NET_FRONT_ORDER_NODE"                 //frontOrder节点根目录;(白质)
#define PATH_NET_FO_ABS_NODE        @"NET_FO_ABS_NODE"                      //神经网络根目录;(白质)

//cmv
#define PATH_NET_CMV_NODE           @"NET_CMV_NODE"                         //cmv节点根目录;(白质)
#define PATH_NET_ABS_CMV_NODE       @"NET_ABS_CMV_NODE"                     //cmv抽象节点根目录;(白质)
#define PATH_NET_DIRECTION(mvDir)   STRFORMAT(@"NET_DIRECTION_%ld",mvDir)   //mv顺逆方向引用序列(以Path为各mv的分区,cmvNode和absCMVNode都指向此direction)

//index
#define PATH_NET_VALUE              @"NET_VALUE"                            //神经网络"值数据"根目录;(海马体)(杏仁核)
#define PATH_NET_ABSVALUE           @"NET_ABSVALUE"                         //"抽象值数据"根目录;

//reference
#define PATH_NET_REFERENCE          @"NET_REFERENCE"                        //神经网络"引用序列"根目录;(海马体)
#define PATH_NET_CEREBEL_CANOUT     @"PATH_NET_CEREBEL_CANOUT"              //小脑可输出标识序列


/**
 *  MARK:--------------------fileNameKey--------------------
 */
#define FILENAME_Node @"node"               //节点
#define FILENAME_Value @"value"             //微信息
#define FILENAME_ValueReference @"valueReference"   //微信息对应的absAlgNode地址;
#define FILENAME_Index(isOut) STRFORMAT(@"index_%d",isOut) //in微信息索引(数组) / out小脑微信息(数组)
#define FILENAME_Reference @"reference"     //微信息引用
#define FILENAME_AbsValue @"absValue"       //宏节点的值存储地址
#define FILENAME_AbsIndex @"absIndex"       //宏节点索引序列地址
#define FILENAME_DirectionIndex(mvDirection) STRFORMAT(@"directionIndex_%ld",mvDirection) //mv的顺逆方向索引序列地址

#define FILENAME_Reference_ByPointer @"reference_ByPointer" //微信息引用(pointer序)
#define FILENAME_Reference_ByPort @"reference_ByPort"       //微信息引用(port序)
#define FILENAME_Default @" "                               //默认文件名; (例如:小脑canout序列)


/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define STRISOK(a) (a  && ![a isKindOfClass:[NSNull class]] && [a isKindOfClass:[NSString class]] && ![a isEqualToString:@""])//是否空字符串
#define STRTOOK(a) (a  && ![a isKindOfClass:[NSNull class]]) ? ([a isKindOfClass:[NSString class]] ? a : [NSString stringWithFormat:@"%@", a]) : @""
#define STRFORMAT(a, ...) [NSString stringWithFormat:a, ##__VA_ARGS__]//String.format

//Array
#define ARRISOK(a) (a  && [a isKindOfClass:[NSArray class]] && a.count)//是否空数组
#define ARRTOOK(a) (a  && [a isKindOfClass:[NSArray class]]) ?  a : [NSArray new]
#define ARR_INDEX(a,i) (a && [a isKindOfClass:[NSArray class]] && a.count > i) ?  a[i] : nil//数组取子防闪
#define ARR_INDEXISOK(a,i) (a && [a isKindOfClass:[NSArray class]] && a.count > i && i >= 0)//数组可移除i

//NSNumber
#define NUMISOK(a) (a  && [a isKindOfClass:[NSNumber class]])//是否有效NSNumber
#define NUMTOOK(a) (a  && [a isKindOfClass:[NSNumber class]]) ? a : @(0)

//Dic
#define DICISOK(a) (a  && [a isKindOfClass:[NSDictionary class]] && a.count)//是否空字典
#define DICTOOK(a) (a  && [a isKindOfClass:[NSDictionary class]]) ?  a : [NSDictionary new]

//AILine
#define LINEISOK(a) (a  && [a isKindOfClass:[AILine class]])

//AIPointer
#define POINTERISOK(a) (a && [a isKindOfClass:[AIPointer class]] && a.pointerId > 0)

//ISOK
#define ISOK(obj, class) (obj && [obj isKindOfClass:class])

/**
 *  MARK:--------------------快捷建对象--------------------
 */

//NSArray
#define SMGArrayMake(arg) \
NSMutableArray *array = [NSMutableArray arrayWithObject:arg];\
va_list args;\
va_start(args, arg);\
id next = nil;\
while ((next = va_arg(args,id))) {\
[array addObject:next];\
}\
va_end(args);\


/**
 *  MARK:--------------------快捷访问对象--------------------
 */
//2017.11.13后启用N8规则DOP架构;
#define theNet [AINet sharedInstance]


/**
 *  MARK:--------------------ObserverKey--------------------
 */
#define kOutputObserver   @"kOutputObserver"


/**
 *  MARK:--------------------RDS (ReactorDataSource)--------------------
 */
#define TEXT_RDS @"TEXT_RDS" //字符输出反射标识
