//
//  AIHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGEnum.h"
#import "SMGUtils.h"
#import "SMGUtils+General.h"
#import "SMGConfig.h"
#import "AINodeBase.h"
#import "AIFoNodeBase.h"
#import "AICMVNodeBase.h"
#import "NVHeader.h"
#import "AIInput.h"
#import "AINet.h"

/**
 *  MARK:--------------------PathNameKey (kPH)--------------------
 */

//algNode
#define kPN_ALG_NODE           @"PN_ALG_NODE"          //Alg节点根目录;(白质)
#define kPN_ALG_ABS_NODE       @"PN_ALG_ABS_NODE"      //AbsAlg节点根目录;(白质)

//foNode
#define kPN_FRONT_ORDER_NODE   @"PN_FRONT_ORDER_NODE"  //frontOrder节点根目录;(白质)
#define kPN_FO_ABS_NODE        @"PN_FO_ABS_NODE"       //神经网络根目录;(白质)

//cmv
#define kPN_CMV_NODE           @"PN_CMV_NODE"          //cmv节点根目录;(白质)
#define kPN_ABS_CMV_NODE       @"PN_ABS_CMV_NODE"      //cmv抽象节点根目录;(白质)
#define kPN_DIRECTION(mvDir)   STRFORMAT(@"PN_DIRECTION_%ld",mvDir)//mv顺逆方向引用序列(以Path为各mv的分区,cmvNode和absCMVNode都指向此direction)

//reference
#define kPN_REFERENCE          @"PN_REFERENCE"         //神经网络"引用序列"根目录;(海马体)
#define kPN_CEREBEL_CANOUT     @"PN_CEREBEL_CANOUT"    //小脑可输出标识序列

#define kPN_INDEX              @"PN_INDEX"             //索引序列
#define kPN_DATA               @"PN_DATA"              //微信息值字典
#define kPN_VALUE              @"PN_VALUE"             //微信息单条值

/**
 *  MARK:--------------------FileNameKey (kFN)--------------------
 */
#define kFNNode @"node"               //节点
//#define kFNValue @"value"             //微信息
#define kFNRefPorts @"refPorts"       //微信息的reference序列文件名;
#define kFNIndex(isOut) STRFORMAT(@"index_%d",isOut) //in微信息索引(数组) / out小脑微信息(数组)
#define kFNData(isOut) STRFORMAT(@"data_%d",isOut) //in微信息值 / out小脑微信息值 (dic)
#define kFNDirectionIndex(mvDirection) STRFORMAT(@"directionIndex_%ld",mvDirection) //mv的顺逆方向索引序列地址

#define kFNReference_ByPointer @"reference_ByPointer" //微信息引用(pointer序)
#define kFNReference_ByPort @"reference_ByPort"       //微信息引用(port序)
#define kFNDefault @" "                               //默认文件名; (例如:小脑canout序列)

#define kFNMemRefPorts @"memRefPorts" //内存网络_微信息的reference序列文件名;
#define kFNMemAbsPorts @"memAbsPorts" //内存网络_抽象序列;
#define kFNMemConPorts @"memConPorts" //内存网络_具象序列;
#define kFNMemNode @"memNode"         //内存网络中节点

#define kFNRefPorts_All(isMem) (isMem ? kFNMemRefPorts : kFNRefPorts) //微信息的reference序列文件名;
//#define kFNAbsPorts_All(isMem) (isMem ? kFNMemAbsPorts : kFNAbsPorts) //抽象序列; (硬盘中存在node下)
//#define kFNConPorts_All(isMem) (isMem ? kFNMemConPorts : kFNConPorts) //具象序列; (硬盘中存在node下)
#define kFNNode_All(isMem) (isMem ? kFNMemNode : kFNNode) //节点

/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define STRISOK(s) [SMGUtils strIsOk:s]                                 //是否空字符串
#define STRTOOK(s) [SMGUtils strToOk:s]                                 //string强检查
#define STRFORMAT(s, ...) [NSString stringWithFormat:s, ##__VA_ARGS__]  //String.format
#define SUBSTR2INDEX(s,index) [SMGUtils subStr:s toIndex:index]         //subStr_toIndex

//Array
#define ARRISOK(a) [SMGUtils arrIsOk:a]                                 //是否空数组
#define ARRTOOK(a) [SMGUtils arrToOk:a]                                 //数组强检查
#define ARR_INDEX(a,i) [SMGUtils arrIndex:a index:i]                    //数组取子防闪
#define ARR_INDEXISOK(a,i) [SMGUtils arrIndexIsOk:a index:i]            //数组可移除i
#define ARR_SUB(a,s,l) [SMGUtils arrSub:a start:s length:l]             //数组截取 (arr start length)

//NSNumber
#define NUMISOK(n) [SMGUtils numIsOk:n]                                 //是否有效NSNumber
#define NUMTOOK(n) [SMGUtils numToOk:n]                                 //number强检查

//Dic
#define DICISOK(d) [SMGUtils dicIsOk:d]                                 //是否空字典
#define DICTOOK(d) [SMGUtils dicToOk:d]                                 //dictionary强检查

//AIPointer
#define POINTERISOK(p) [SMGUtils pointerIsOk:p]                         //指针强检查

//ISOK
#define ISOK(o, c) [SMGUtils isOk:o class:c]                            //obj强检查 (object class)

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
#define theTC [AIThinkingControl shareInstance]


/**
 *  MARK:--------------------ObserverKey--------------------
 */
#define kOutputObserver   @"kOutputObserver"


/**
 *  MARK:--------------------RDS (ReactorDataSource)--------------------
 */
#define TEXT_RDS @"TEXT_RDS" //字符输出反射标识
#define ANXIOUS_RDS @"ANXIOUS_RDS" //焦急情绪输出标识
#define SATISFY_RDS @"SATISFY_RDS" //满意情绪输出标识

/**
 *  MARK:--------------------AlgsType & DataSource--------------------
 */
#define DefaultAlgsType @" "    //默认AlgsType
#define DefaultDataSource @" "  //默认DataSource
#define AlgNodeAlgsType(pId) STRFORMAT(@"%ld",(long)pId)   //概念节点AlgsType

/**
 *  MARK:--------------------LOG--------------------
 */
#define ELog(fmt, ...) NSLog((@"error!!!  %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define WLog(fmt, ...) NSLog((@"warning???  %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
