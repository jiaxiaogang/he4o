//
//  AIThinkOutAnalogy.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/12/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutAnalogy.h"
#import "AIAbsAlgNode.h"
#import "AINetUtils.h"

@implementation AIThinkOutAnalogy

/**
 *  MARK:--------------------MC类比--------------------
 *  @param complete : return mcs&ms&cs notnull
 *  @desc 缩写说明: m = matchAlg, c = curAlg, mcs = MCSame, ms = MSpecial, cs = CSpecial
 */
+(void) mcAnalogy:(AIAlgNodeBase*)mAlg cAlg:(AIAlgNodeBase*)cAlg complete:(void(^)(NSArray *mcs,NSArray *ms,NSArray *cs))complete{
    //1. 数据准备
    if (!mAlg || !cAlg) {
        return;
    }
    NSMutableArray *mcs = [[NSMutableArray alloc] init];
    NSMutableArray *ms = [[NSMutableArray alloc] init];
    NSMutableArray *cs = [[NSMutableArray alloc] init];
    
    //2. 收集m_ps & c_ps & mc_ps;
    NSArray *mAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:mAlg]];
    NSArray *cAbs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All:cAlg]];
    NSMutableArray *mcAbs_ps = [[NSMutableArray alloc] init];
    [mcAbs_ps addObjectsFromArray:mAbs_ps];
    [mcAbs_ps addObjectsFromArray:cAbs_ps];
    
    //3. 收集mcs & ms & cs;
    for (AIPointer *item_p in mcAbs_ps) {
        BOOL mContains = [SMGUtils containsSub_p:item_p parent_ps:mAbs_ps];
        BOOL cContains = [SMGUtils containsSub_p:item_p parent_ps:cAbs_ps];
        if (mContains && cContains) {
            if (![SMGUtils containsSub_p:item_p parent_ps:mcs]) [mcs addObject:item_p];
        }else if(mContains){
            if (![SMGUtils containsSub_p:item_p parent_ps:ms]) [ms addObject:item_p];
        }else if(cContains){
            if (![SMGUtils containsSub_p:item_p parent_ps:cs]) [cs addObject:item_p];
        }
    }
    
    //4. 返回_MC进行评价;
    if (complete) complete(mcs,ms,cs);
}

@end
