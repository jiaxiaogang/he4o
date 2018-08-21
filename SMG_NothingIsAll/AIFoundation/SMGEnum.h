//
//  SMGEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

/**
 *  MARK:--------------------输出表情类型--------------------
 */
typedef NS_ENUM(NSInteger, OutputFaceType) {
    OutputFaceType_Cry      = 0,
    OutputFaceType_Smile    = 1,
};

/**
 *  MARK:--------------------输出类型--------------------
 */
typedef NS_ENUM(NSInteger, OutputType) {
    OutputType_Face     = 0,
    OutputType_Text     = 1,
};


/**
 *  MARK:--------------------表情喜怒(外)--------------------
 */
typedef NS_ENUM(NSInteger, JoyAngerType) {
    JoyAngerType_Joy = 0,
    JoyAngerType_Anger = 1,
};

/**
 *  MARK:--------------------心情--------------------
 */
typedef NS_ENUM(NSInteger, MoodType) {
    MoodType_Irritably2Calm  =   0,//急燥心静
};

/**
 *  MARK:--------------------充电状态--------------------
 */
typedef NS_ENUM(NSInteger, HungerState) {
    HungerState_Unknown     = 0,
    HungerState_Unplugged   = 1,//未充电
    HungerState_Charging    = 2,//充电中
};

/**
 *  MARK:--------------------Aw2DemandStatus--------------------
 */
typedef NS_ENUM(NSInteger, Aw2DemandStatus) {
    Aw2DemandStatus_None       = 0,
    Aw2DemandStatus_IO         = 1,//IO
    Aw2DemandStatus_NoMain     = 2,
    Aw2DemandStatus_MainWait   = 3,//主任务生成等待
    Aw2DemandStatus_MainCommit = 4,//主任务提交
    Aw2DemandStatus_Finish     = 5,//finish(Awareness->Demand的意识分析完成)
};

/**
 *  MARK:--------------------AILogicKeyType--------------------
 */
typedef NS_ENUM(NSInteger, AILogicKeyType) {
    AILogicKeyType_None = 0,//无
    AILogicKeyType_Break = 1,//break;
    AILogicKeyType_Continue = 2,
};

typedef NS_ENUM(NSInteger, AIMoodType) {
    AIMoodType_Anxious      = 1,//焦急
    AIMoodType_Satisfy      = 2,//满意
};

/**
 *  MARK:--------------------网络多维类型--------------------
 */
typedef NS_ENUM(NSInteger, NetDimensionType) {
    NetDimensionType_Str      = 1,//字符串
};

/**
 *  MARK:--------------------MV规则类型--------------------
 */
typedef NS_ENUM(NSInteger, MVRuleType) {
    MVRuleType_None           = 0,//None
    MVRuleType_Back           = 1,//归零
    MVRuleType_Loop           = 2,//重复
    MVRuleType_Add            = 3,//增涨
};

/**
 *  MARK:--------------------MVInput值与感受值的曲线算法类型--------------------
 */
typedef NS_ENUM(NSInteger, MVUpCurveType) {
    MVUpCurveType_LINEAR    = 1,//线性
    MVUpCurveType_AND       = 2,//越来越高
};

/**
 *  MARK:--------------------MVValue值与衰减曲线算法类型--------------------
 */
typedef NS_ENUM(NSInteger, MVDownCurveType) {
    MVDownCurveType_LINEAR     = 1,//线性
    MVDownCurveType_AND        = 2,//越来越低
};

/**
 *  MARK:--------------------IMVType(输入imv信号)--------------------
 */
typedef NS_ENUM(NSInteger, MVType) {
    MVType_None     = 0,
    MVType_Hunger   = 1,
    MVType_Anxious  = 2,
};

/**
 *  MARK:--------------------CustomInputType(自定义输入信号)--------------------
 */
typedef NS_ENUM(NSInteger, CustomInputType) {
    CustomInputType_Charge     = 1,
};

/**
 *  MARK:--------------------MultiNetType--------------------
 */
typedef NS_ENUM(NSInteger, MultiNetType) {
    MultiNetType_Unknown        = 0,//UnKnown
    MultiNetType_Logic          = 1,//Logic
    MultiNetType_String         = 2,//String
};

/**
 *  MARK:--------------------神经元类型--------------------
 */
typedef NS_ENUM(NSInteger, AINodeType) {
    AINodeType_Data         = 0,//单路神经元
    AINodeType_Func         = 1,//双路神经元
    AINodeType_MultiFunc    = 2,//多路神经元
};

/**
 *  MARK:--------------------ComparisonType--------------------
 */
typedef NS_ENUM(NSInteger, ComparisonType) {
    ComparisonType_Than     = 0,
    ComparisonType_Equal    = 1,
    ComparisonType_Less     = 2,
};

/**
 *  MARK:--------------------MindType(最基础的需求)--------------------
 */
typedef NS_ENUM(NSInteger, MindType) {
    MindType_Hunger     =   0,//饥饿
    MindType_Happy      =   1,//开心
    MindType_Algesia    =   2,//痛觉
};

/**
 *  MARK:--------------------数据网络,节点类型--------------------
 */
typedef NS_ENUM(NSInteger, AIDataType) {
    AIDataType_Int      = 1,
    AIDataType_Float    = 2,
    AIDataType_Change   = 3,
    AIDataType_File     = 4,
    AIDataType_Char     = 4,
    AIDataType_String   = 4,
    AIDataType_Mp3      = 5,//SubX
    AIDataType_Mp4      = 6,
};

/**
 *  MARK:--------------------AILineType--------------------
 */
typedef NS_ENUM(NSInteger, AILineType) {
    ALT_Property    = 0,//包含关系 (RName)
    ALT_ValueIs     = 1,//值关系
    ALT_IsA         = 2,//继承关系
    ALT_MBy         = 3,//被调用关系
    ALT_MCan        = 4,//实现关系
    ALT_MTarget     = 5,//逻辑(指向)关系
    ALT_MResult     = 6,//逻辑(触发)关系
    ALT_Instance    = 7,//实例关系
};

/**
 *  MARK:--------------------MV目标类型--------------------
 */
typedef NS_ENUM(NSInteger, AITargetType) {
    AITargetType_None   = 0,//不变
    AITargetType_Up     = 1,//增涨(欲望)
    AITargetType_Down   = 2,//下降(饥饿,焦急)
    AITargetType_Repeat = 3,//重复(快乐)
};

/**
 *  MARK:--------------------PortType--------------------
 */
typedef NS_ENUM(NSInteger, PortType) {
    PortType_Abs        = 1,
    PortType_Con        = 2,
    PortType_Property   = 3,
    PortType_BeProperty = 4,
    PortType_Change     = 5,
    PortType_BeChange   = 6,
    PortType_Logic      = 7,
    PortType_BeLogic    = 8,
};

/**
 *  MARK:--------------------顺逆方向--------------------
 */
typedef NS_ENUM(NSInteger, MVDirection) {
    MVDirection_Negative    = 0,//负
    MVDirection_Positive    = 1,//正
};

/**
 *  MARK:--------------------顺心类型--------------------
 */
typedef NS_ENUM(NSInteger, MindHappyType) {
    MindHappyType_None    = 0,//没影响
    MindHappyType_Yes    = 1,//顺心
    MindHappyType_No    = 2,//不顺心
    
};
