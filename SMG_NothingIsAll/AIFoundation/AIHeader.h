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
#import "HeLogHeader.h"
#import "AIKVPointer.h"
#import "AIThinkingControl.h"
#import "NSString+Extension.h"
#import "AIScore.h"
#import "OutputModel.h"
#import "XGDelegate.h"
#import "ThinkingUtils.h"
#import "TOUtils.h"
#import "TOModelVision.h"

//MARK:===============================================================
//MARK:                         < 内核宏 >
//MARK:===============================================================

/**
 *  MARK:--------------------PathNameKey (kPH)--------------------
 */

#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

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
#define kFNMemDBPorts @"memDiffBasePorts" //内存网络_DB序列;
#define kFNMemDSPorts @"memDiffSubPorts" //内存网络_DS序列;
#define kFNMemNode @"memNode"         //内存网络中节点

#define kFNRefPorts_All(isMem) (isMem ? kFNMemRefPorts : kFNRefPorts) //微信息的reference序列文件名;
//#define kFNAbsPorts_All(isMem) (isMem ? kFNMemAbsPorts : kFNAbsPorts) //抽象序列; (硬盘中存在node下)
//#define kFNConPorts_All(isMem) (isMem ? kFNMemConPorts : kFNConPorts) //具象序列; (硬盘中存在node下)
#define kFNNode_All(isMem) (isMem ? kFNMemNode : kFNNode) //节点

//所有文件夹数组
#define kFN_ALL @[/*mvNode*/kPN_CMV_NODE,kPN_ABS_CMV_NODE,/*mv索引*/kPN_DIRECTION(MVDirection_None),kPN_DIRECTION(MVDirection_Negative),kPN_DIRECTION(MVDirection_Positive),/*foNode*/kPN_FRONT_ORDER_NODE,kPN_FO_ABS_NODE,/*algNode*/kPN_ALG_NODE,kPN_ALG_ABS_NODE,/*小脑*/kPN_CEREBEL_CANOUT,/*稀疏码索引*/kPN_INDEX,kPN_DATA,kPN_VALUE];

/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define STRISOK(s) [SMGUtils strIsOk:s]                                 //是否空字符串
#define STRTOOK(s) [SMGUtils strToOk:s]                                 //string强检查
#define STRFORMAT(s, ...) [NSString stringWithFormat:s, ##__VA_ARGS__]  //String.format
#define SUBSTR2INDEX(s,index) [SMGUtils subStr:s toIndex:index]         //subStr_toIndex
#define STRTOARR(str, sep) [SMGUtils strToArr:str sep:sep]              //str分隔成arr

//Array
#define ARRISOK(a) [SMGUtils arrIsOk:a]                                 //是否空数组
#define ARRTOOK(a) [SMGUtils arrToOk:a]                                 //数组强检查
#define ARR_INDEX(a,i) [SMGUtils arrIndex:a index:i]                    //数组取子防闪
#define ARR_INDEX_REVERSE(a,i) [SMGUtils arrTransIndex:a index:i]          //数组反序取子防闪
#define ARR_INDEXISOK(a,i) [SMGUtils arrIndexIsOk:a index:i]            //数组可移除i
#define ARR_SUB(a,s,l) [SMGUtils arrSub:a start:s length:l]             //数组截取 (arr start length)

//NSNumber
#define NUMISOK(n) [SMGUtils numIsOk:n]                                 //是否有效NSNumber
#define NUMTOOK(n) [SMGUtils numToOk:n]                                 //number强检查
#define NUMTOOK_DV(n,dv) [SMGUtils numToOk:n defaultValue:dv]

//Dic
#define DICISOK(d) [SMGUtils dicIsOk:d]                                 //是否空字典
#define DICTOOK(d) [SMGUtils dicToOk:d]                                 //dictionary强检查

//AIPointer
#define POINTERISOK(p) [SMGUtils pointerIsOk:p]                         //指针强检查
#define PitIsValue(p) [NVHeUtil isValue:p]                              //是否稀疏码
#define PitIsAlg(p) [NVHeUtil isAlg:p]                                  //是否概念
#define PitIsFo(p) [NVHeUtil isFo:p]                                    //是否时序
#define PitIsMv(p) [NVHeUtil isMv:p]                                    //是否价值
#define PitIsAbs(p) [NVHeUtil isAbs:p]                                  //是否抽象节点

//ISOK
#define ISOK(o, c) [SMGUtils isOk:o class:c]                            //obj强检查 (object class)

//NSData
#define OBJ2DATA(obj) [NSKeyedArchiver archivedDataWithRootObject:obj]
#define DATA2OBJ(data) [NSKeyedUnarchiver unarchiveObjectWithData:data]
#define DATAS2OBJS(datas) [SMGUtils datas2Objs:datas]

//指针转字符串
#define Pit2FStr(p) [NVHeUtil getLightStr:p simple:false header:true]
#define Pits2FStr(ps) [NVHeUtil getLightStr4Ps:ps simple:false header:true sep:@","]
#define Pits2FStr_MultiLine(ps) [NVHeUtil getLightStr4Ps:ps simple:false header:true sep:@"\n"]

#define Pit2SStr(p) [NVHeUtil getLightStr:p]
#define Pits2SStr(ps) [NVHeUtil getLightStr4Ps:ps]

//节点转字符串
#define Alg2FStr(a) [NVHeUtil getLightStr:a.pointer simple:false header:true]
#define Fo2FStr(f) [NVHeUtil getLightStr:f.pointer simple:false header:true]
#define Mv2FStr(m) [NVHeUtil getLightStr:m.pointer simple:false header:true]

#define AlgP2FStr(a_p) [NVHeUtil getLightStr:a_p simple:false header:true]
#define FoP2FStr(f_p) [NVHeUtil getLightStr:f_p simple:false header:true]
#define Mvp2Str(m_p) [NVHeUtil getLightStr:m_p simple:false header:true]

//稀疏码值转字符串
#define Data2FStr(data,at,ds) [NVHeUtil getLightStr_Value:data algsType:at dataSource:ds]

//xxx转指针
#define Ports2Pits(ports) [SMGUtils convertPointersFromPorts:ports]
#define Nodes2Pits(nodes) [SMGUtils convertPointersFromNodes:nodes]
#define TOModels2Pits(toModels) [TOUtils convertPointersFromTOModels:toModels];
#define RDemands2Pits(rDemands) [TOUtils convertPointersFromRDemands:rDemands];

//AnalogType转字符串
#define ATType2Str(type) [NSLog_Extension convertATType2Desc:type]
#define TOStatus2Str(status) [NSLog_Extension convertTOStatus2Desc:status]
#define TIStatus2Str(status) [NSLog_Extension convertTIStatus2Desc:status]
#define Class2Str(c) [NSLog_Extension convertClass2Desc:c]
#define Mvp2DeltaStr(mv_p) [NSLog_Extension convertMvp2DeltaDesc:mv_p]

//Double转Str
#define Double2Str_NDZ(value) [NSString double2Str_NoDotZero:value]

//思维控制器相关转换
//#define ATType2DS(type) [ThinkingUtils getAnalogyTypeDS:type]
//#define DS2ATType(ds) [ThinkingUtils convertDS2AnalogyType:ds]
#define Mvp2Delta(mv_p) [AINetUtils getDeltaFromMv:mv_p]
#define Mvp2Score(mv_p,ratio) [AIScore score4MV:mv_p ratio:ratio]

//短时记忆转字符串
#define TOModel2Root2Str(sub) [TOModelVision cur2Root:sub]
#define TOModel2Sub2Str(cur) [TOModelVision cur2Sub:cur]


/**
 *  MARK:--------------------快捷建对象--------------------
 */

//NSArray
//#define SMGArrayMake(arg) \
//NSMutableArray *array = [NSMutableArray arrayWithObject:arg];\
//va_list args;\
//va_start(args, arg);\
//id next = nil;\
//while ((next = va_arg(args,id))) {\
//[array addObject:next];\
//}\
//va_end(args);\

/**
 *  MARK:--------------------快捷访问对象--------------------
 */
//2017.11.13后启用N8规则DOP架构;
#define theNet [AINet sharedInstance]
#define theTC [AIThinkingControl shareInstance]


/**
 *  MARK:--------------------OutputObserverKey--------------------
 */
//OutputObserverKey
#define kOutputObserver   @"kOutputObserver"

//OutputObjectKey (2021.02.05: 改为直接用OutputModel做obj);
//#define kOOIdentify @"identify" //输出行为标识
//#define kOOParam @"param"       //输出行为参数值
//#define kOOType @"type"         //广播类型
//#define kOOUseTime @"useTime"   //反馈需用时

//Identify标识 (内核方)
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
//日志默认header模式 (当前为首行显示)
#define DefaultHeaderMode 2
//当前类名
#define FILENAME [[NSString stringWithUTF8String:__FILE__] lastPathComponent]
//errorLog
#define ELog(fmt, ...) NSLog((@"<错误> " fmt), ##__VA_ARGS__);
//warnLog
#define WLog(fmt, ...) NSLog((@"<警告> " fmt), ##__VA_ARGS__);
//demoLog (Demo交互信息)
#define DemoLog(fmt, ...) NSLog((@"\n********************************************* " fmt @" *********************************************"), ##__VA_ARGS__);
//titleLog (控制台日志组块title) (其实S为简化版,F为全版,I为输入期,O为输出期);
#define ISTitleLog(title) IFTitleLog(title,@"")
#define IFTitleLog(title,fmt, ...) NSLog((@"\n\n------------------------------- " title @" -------------------------------"fmt), ##__VA_ARGS__);
#define OSTitleLog(title) OFTitleLog(title,@"")
#define OFTitleLog(title,fmt, ...) NSLog((@"\n\n=============================== " title @" ==============================="fmt), ##__VA_ARGS__);
//系统log (格式化)
#define NSLog(FORMAT, ...) fprintf(stderr,"%s",[[SMGUtils nsLogFormat:FILENAME line:__LINE__ protoLog:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] headerMode:DefaultHeaderMode] UTF8String]);
#define NSLog_Mode(mode,FORMAT, ...) fprintf(stderr,"%s",[[SMGUtils nsLogFormat:FILENAME line:__LINE__ protoLog:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] headerMode:mode] UTF8String]);
//heLog (持久化日志)
#define HeLog(fmt, ...) [theApp.heLogView addLog:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
//tipLog (UI弹出日志)
#define TipLog(fmt, ...) [theApp setTipLog:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
//allLog (系统 + 持久化 + UI弹出)
#define AllLog(fmt, ...) [SMGUtils allLog:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]

/**
 *  MARK:--------------------LOG开关--------------------
 */
//皮层
#define Log4CortexAlgs false
//输入思维
#define Log4TCInput false
//识别概念
#define Log4MAlg false
//模糊匹配
#define Log4FuzzyAlg false
//识别时序
#define Log4MFo false
#define Log4AnalogyAbsRFo true
//内类比
#define Log4InAna false
#define Log4InAnaGL(type) ((type == ATGreater || type == ATLess) && false)
#define Log4InAnaHN(type) ((type == ATHav || type == ATNone) && false)

//外类比
#define Log4OutAna false
#define Log4OutAnaGL(type) (!Log4OutAna && ((type == ATGreater || type == ATLess) && false))
#define Log4OutAnaHN(type) (!Log4OutAna && ((type == ATHav || type == ATNone) && false))
#define Log4OutAnaSP(type) (!Log4OutAna && ((type == ATSub || type == ATPlus) && true))
#define Log4OutAnaDiff(type) (!Log4OutAna && (type == ATDiff && false))
//#define Log4OutAnaSame(type) (!Log4OutAna && (type == ATSame && false))
#define Log4OutAnaDefault(type) (!Log4OutAna && (type == ATDefault && false))
#define Log4OutAnaType(type) Log4OutAna || Log4OutAnaGL(type) || Log4OutAnaHN(type) || Log4OutAnaSP(type) || Log4OutAnaDiff(type) || Log4OutAnaDefault(type)//有一项符合时,则打印

//正向类比
#define Log4SameAna true
//反向类比
#define Log4DiffAna true
//方向索引
#define Log4DirecRef true
//行为化_GL
#define Log4ActGL true
//行为化_Hav
#define Log4ActHav false
//行为化_RelativeFos
#define Log4ActRelativeFos false
//行为化_GetInnerAlg
#define Log4GetInnerAlg true
//PM算法
#define Log4PM true
//外输入推进中循环
#define Log4OPushM true
#define Log4TIROPushM false
//VRS评价
#define Log4VRS_Main true
#define Log4VRS_Desc false
//In反省
#define Log4InRethink true
#define Log4OutRethink true
#define Log4Rethink true

//MARK:===============================================================
//MARK:                     < 系统模块开关 >
//MARK:===============================================================

//R决策模式
#define Switch4RS true
//P决策模式
#define Switch4PS false
