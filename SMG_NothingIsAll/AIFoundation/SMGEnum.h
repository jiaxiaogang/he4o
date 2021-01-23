//
//  SMGEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

/**
 *  MARK:--------------------充电状态--------------------
 */
typedef NS_ENUM(NSInteger, HungerState) {
    HungerState_Unknown     = 0,
    HungerState_Unplugged   = 1,//未充电
    HungerState_Charging    = 2,//充电中
};


typedef NS_ENUM(NSInteger, AIMoodType) {
    AIMoodType_Anxious      = 1,//焦急
    AIMoodType_Satisfy      = 2,//满意
};

/**
 *  MARK:--------------------IMVType(输入imv信号)--------------------
 */
typedef NS_ENUM(NSInteger, MVType) {
    MVType_None     = 0,
    MVType_Hunger   = 1,
    MVType_Anxious  = 2,
    MVType_Hurt  = 3,//痛觉
};

/**
 *  MARK:--------------------CustomInputType(自定义输入信号)--------------------
 */
typedef NS_ENUM(NSInteger, CustomInputType) {
    CustomInputType_Charge     = 1,
};

/**
 *  MARK:--------------------MV目标类型--------------------
 */
typedef NS_ENUM(NSInteger, AITargetType) {
    AITargetType_None   = 0,//不变
    AITargetType_Up     = 1,//增涨(欲望)
    AITargetType_Down   = 2,//下降(饥饿,焦急,疼痛)
    AITargetType_Repeat = 3,//重复(快乐)
};


/**
 *  MARK:--------------------顺逆方向--------------------
 */
typedef NS_ENUM(NSInteger, MVDirection) {
    MVDirection_None        =-1,//无
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

/**
 *  MARK:--------------------类比类型(大小有无同异)--------------------
 */
typedef NS_ENUM(NSInteger,  AnalogyType) {
    ATDefault   = 0,            //默认
    ATGreater   = INT_MAX - 47, //2147483600    内类比_变大
    ATLess      = INT_MIN + 48, //-2147483600   内类比_变小
    ATHav       = INT_MAX,      //2147483647    内类比_变有
    ATNone      = INT_MIN,      //-2147483648   内类比_变无
    ATPlus      = INT_MAX - 147,//2147483500    反省_可行
    ATSub       = INT_MIN + 148,//-2147483500   反省_不可行
    ATSame      = INT_MAX - 247,//2147483400    正向类比
};

/**
 *  MARK:--------------------Output通知前后枚举--------------------
 */
typedef NS_ENUM(NSInteger,  OutputObserverType) {
    OutputObserverType_Front   = 0,//前
    OutputObserverType_Back    = 1,//后
};

/**
 *  MARK:--------------------识别类型--------------------
 *  @desc 优先级说明: self > fuzzy > abs > seem
 *  @version
 *      2020.10.22: TIR_Alg同时支持matchAlg和seemAlg的返回,fuzzy已废弃,所以不再需要MatchType枚举 (参考:21091);
 */
//typedef NS_ENUM(NSInteger, MatchType) {
//    MatchType_None  = 0,//无效
//    MatchType_Seem  = 1,//局部相似
//    MatchType_Abs   = 2,//全含
//    MatchType_Fuzzy = 3,//模糊匹配
//    MatchType_Self  = 4,//自身
//};

/**
 *  MARK:--------------------LogHeaderMode--------------------
 */
typedef NS_ENUM(NSInteger, LogHeaderMode) {
    LogHeaderMode_None  = 0,//无header
    LogHeaderMode_First = 1,//仅首行
    LogHeaderMode_All   = 2,//所有行
};

/**
 *  MARK:--------------------TOModelStatus--------------------
 *  @title 输出模型状态
 *  @todo 考虑支持ScorePK,即迟疑时,尝试别的方案,与当前方案进行竞争;
 */
typedef NS_ENUM(NSInteger, TOModelStatus) {
    TOModelStatus_Wait     = 0,//等待行为化 (行为化前,尝试找各种解决方案);
    TOModelStatus_Runing   = 1,//运行中 (其subModel正在尝试行为化中);
    TOModelStatus_ActYes   = 2,//行为化成功 (等待外循环结果,等待反馈);
    TOModelStatus_ActNo    = 3,//行为化失败 (等待条件满足时继续);
    TOModelStatus_ScoreNo  = 4,//评价失败而中止 (不想干,彻底挂掉,除非demandModel变的更迫切);
    TOModelStatus_NoNeedAct= 5,//无需行为化
    TOModelStatus_OuterBack= 6,//外循环结果返回符合的标记 (mIsC 或 GL符合变化);
    TOModelStatus_Finish   = 7,//最终成功 (完成后向下帧跳转,发生在事实发生之后,即新的input匹配到);
    TOModelStatus_VSWait   = 8,//在多任务竞争中,被暂时击退 (等待继续博弈);
};

/**
 *  MARK:--------------------TIModelStatus--------------------
 *  @title 输入模型状态
 */
typedef NS_ENUM(NSInteger, TIModelStatus) {
    TIModelStatus_Default   = 0,//默认值
    TIModelStatus_LastWait  = 1,//末位等待
    TIModelStatus_OutBackYes= 2,//返馈成功
    TIModelStatus_OutBackNo = 3,//返馈失败
};

/**
 *  MARK:--------------------TOType--------------------
 *  @title 决策类型 (其实只有P-和R-存在,另外两个不构成需求);
 */
//typedef NS_ENUM(NSInteger, TOType) {
//    TO_PerceptSub = 0,//P- (必须完成,才算完成)
//    TO_PerceptPlus= 1,//P+ (开心,无需求,暂废弃)
//    TO_ReasonPlus = 2,//R+ (顺应即可,顺不成也算完成,无需求,暂废弃)
//    TO_ReasonSub  = 3,//R- (只要阻止,就算完成)
//};
