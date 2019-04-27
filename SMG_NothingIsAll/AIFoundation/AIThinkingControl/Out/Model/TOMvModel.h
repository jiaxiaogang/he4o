//
//  TOMvModel.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/21.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

/**
 *  MARK:--------------------解决经验model(OMV)--------------------
 *  content_p1 : mvNode_p_referencePort对应的absMvNode地址;
 *  content_p2 : 经验指针;用以absNode,联想具象,并找到执行方案;
 *  score1 : 执行性初始分;
 *  score2 : 因mindHappy和urgentTo算出的可行性;
 *  score3 : V2TODO:后续增加主观意志,对order的影响;从而使TOMvModel的思考更加灵活;
 */
@interface TOMvModel : TOModelBase

@end
