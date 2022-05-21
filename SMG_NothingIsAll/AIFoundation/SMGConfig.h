//
//  SMGConfig.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < redisTime >
//MARK:===============================================================
#define cRTIndex 315360000  //常驻内存(十年)
#define cRTData 315360000   //常驻内存(十年)
#define cRTReference 600    //微信息索引序列时间;
#define cRTNode 200         //所有node时间
#define cRTDefault 60       //默认,例如:小脑canout序列;
#define cRTPort 200         //refPorts(概念),absPorts,conPorts的时间;
#define cRTMvRef 600        //mv方向索引时间;

#define cRTMemDefault 1800  //内存网络_默认生存时间;
#define cRTMemNode 1800     //内存网络_Node时间;
#define cRTMemPort 1800     //内存网络_Port时间;
#define cRTMemReference 1800//内存网络_微信息引用序列
#define cRTMemMvRef 1800    //mv方向索引时间;

#define cRTNode_All(isMem) (isMem ? cRTMemNode : cRTNode)
#define cRTPort_All(isMem) (isMem ? cRTMemPort : cRTPort)
#define cRTReference_All(isMem) (isMem ? cRTMemReference : cRTReference)    //微信息索引序列
#define cRTMemMvRef_All(isMem) (isMem ? cRTMemMvRef : cRTMvRef)             //mv方向索引时间;

//MARK:===============================================================
//MARK:                     < thinkingControl >
//MARK:===============================================================
#define cAssDataLimit 2 //应以当前整体思维活跃度,变化为1-3左右;
#define cMinEnergy 0 //思维活力限低
#define cMaxEnergy 20 //思维活力限高
#define cShortMemoryLimit 4 //瞬时记忆最多8条 (20200329训练内类比时,8->4,因为估计4条足够v2.0用了);
//#define cActiveCacheLimit 50//激活缓存最多50条; (废弃,因为改为瞬时匹配模型)

//MARK:===============================================================
//MARK:                     < ThinkOut >
//MARK:===============================================================
#define cDataOutAssFoCount 3    //在决策过程中,foScheme横向最大检索条数;
#define cDataOutAssFoDeep 3     //在决策过程中,foScheme纵向最大检索深度;

#define cDataOutAssAlgCount 5   //在决策过程中,algScheme横向最大检索条数;
#define cDataOutAssAlgDeep 2    //在决策过程中,algScheme纵向最大检索深度;

#define cHavNoneAssFoCount 5    //Hav和None在联想其fo时,最大条数 (getInnerV3迭代后,不需要refPorts了,所以废弃);
#define cGetInnerAbsLayer 2     //getInner()中,Alg纵向尝试layer层 (20210514改成2,因为1和8层也会直接抽具象关联);
#define cGetInnerAbsCount 3     //getInner()中,Alg纵向每层取limit个;
#define cGetInnerByAlgCount 3   //getInnerHN()中,type嵌套取limit条;
#define cGetInnerByFoCount 3    //getInnerGL()中,type嵌套取limit条;

#define cTOSubModelLimit 2      //在决策中,子模型limit

#define cMCValue_AbsAssLimit 10 //在MC匹配稀疏码模糊匹配时,向抽象联想个数
#define cMCValue_ConAssLimit 20 //在MC匹配稀疏码模糊匹配时,向具象联想个数
#define cPM_RefLimit 20         //在PM理性评价时,取refPorts的个数 (参考20063-A2示图)
#define cPM_CheckRefLimit 4     //在PM理性评价时,检查有效(有mv指向)refPorts的个数
#define cPM_CheckSPFoLimit 100    //在PM理性评价时,检查SP时序的个数

#define cTOPPModeConAssLimit 5  //在TOP的P模式下,下具象联想的条数

#define cRethinkActBack_AssSPFoLimit 3 //反省_联想ATSubFo的数量
#define cDemandDeepLimit 8 //短时记忆树最高demand层数;


//MARK:===============================================================
//MARK:                     < ThinkIn >
//MARK:===============================================================
#define cMvNoneIdent @"mvNone"      //mv的默认标识

/**
 *  MARK:--------------------局部匹配时,检查refPorts数--------------------
 *  @version 2020.07.20: 概念经历太多时,10个太少找不到本该出现的结果,所以改成IntMax,因为无性能问题
 */
#define cPartMatchingCheckRefPortsLimit_Alg NSIntegerMax
#define cPartMatchingThreshold 0.3  //局部匹配时_匹配阀值 (相似度) 20191224ALG改为全含方式 FO懒先不改
#define cTIRFoAbsIndexLimit 5       //时序识别时,取抽象索引的条数

//MARK:===============================================================
//MARK:                     < 窄出 >
//MARK:===============================================================
#define cValueNarrowLimit 1000
#define cAlgNarrowLimit 5
#define cFoNarrowLimit 5
#define cSolutionNarrowLimit 3
