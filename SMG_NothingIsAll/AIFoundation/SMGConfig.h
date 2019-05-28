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
#define cRTReference 600
#define cRTNode 200
#define cRTDefault 60       //默认,例如:小脑canout序列;
#define cRTPort 200

#define cRTMemDefault 1800  //内存网络_默认生存时间;
#define cRTMemNode 1800     //内存网络_Node时间;
#define cRTMemPort 1800     //内存网络_Port时间;
#define cRTMemReference 1800//内存网络_微信息引用序列

#define cRTNode_All(isMem) (isMem ? cRTMemNode : cRTNode)
#define cRTPort_All(isMem) (isMem ? cRTMemPort : cRTPort)
#define cRTReference_All(isMem) (isMem ? cRTMemReference : cRTReference)

//MARK:===============================================================
//MARK:                     < thinkingControl >
//MARK:===============================================================
#define cAssDataLimit 2 //应以当前整体思维活跃度,变化为1-3左右;
#define cMinEnergy 0 //思维活力限低
#define cMaxEnergy 20 //思维活力限高
#define cShortMemoryLimit 8 //瞬时记忆最多8条

//MARK:===============================================================
//MARK:                     < ThinkOut >
//MARK:===============================================================
#define cDataOutAssFoCount 3    //在决策过程中,foScheme横向最大检索条数;
#define cDataOutAssFoDeep 3     //在决策过程中,foScheme纵向最大检索深度;

#define cDataOutAssAlgCount 5   //在决策过程中,algScheme横向最大检索条数;
#define cDataOutAssAlgDeep 2    //在决策过程中,algScheme纵向最大检索深度;

#define cGreater NSIntegerMax   //表示内类比算法中,比大小时的大;
#define cLess NSIntegerMin      //表示内类比算法中,比大小时的大;

#define cHav NSIntegerMax - 1   //表示内类比算法中,祖母的有
#define cNone NSIntegerMin + 1  //表示内类比算法中,祖母的无

#define cHavNoneAssFoCount 5    //Hav和None在联想其fo时,最大条数;

#define cTOSubModelLimit 2      //在决策中,子模型limit

//MARK:===============================================================
//MARK:                     < ThinkIn >
//MARK:===============================================================
#define cMvNoneIdent @"mvNone"     //mv的默认标识
