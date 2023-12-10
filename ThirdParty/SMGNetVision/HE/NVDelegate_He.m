//
//  NVDelegate_He.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVDelegate_He.h"
#import "AIKVPointer.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"
#import "AIAbsCMVNode.h"
#import "AINetIndex.h"
#import "ThinkingUtils.h"
#import "CustomAddNodeWindow.h"
#import "NVHeUtil.h"
#import "NVModuleView.h"
#import "NVNodeView.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "TOUtils.h"
#import "LongTipWindow.h"
#import "TVUtil.h"

#define ModuleName_Value @"稀疏码"
#define ModuleName_Alg @"概念网络"
#define ModuleName_Fo @"时序网络"
#define ModuleName_Mv @"价值网络"

#define ColorH UIColorWithRGBHex(0xFFFFFF)//有白
#define ColorN UIColorWithRGBHex(0x000000)//无黑
#define ColorG UIColorWithRGBHex(0x0000FF)//大蓝
#define ColorL UIColorWithRGBHex(0xFFFF00)//小黄
#define ColorP UIColorWithRGBHex(0x00FF00)//好绿
#define ColorS UIColorWithRGBHex(0xFF0000)//坏红

@implementation NVDelegate_He

/**
 *  MARK:--------------------NVViewDelegate--------------------
 */
- (UIView *)nv_GetCustomSubNodeView:(AIKVPointer*)node_p{
    return nil;
}

-(UIColor *)nv_GetNodeColor:(AIKVPointer*)node_p{
    //1. mv节点:(上升为绿&下降为红)
    if ([NVHeUtil isMv:node_p]) {
        AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
        if (mvNode) {
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            MVDirection demand = [ThinkingUtils getDemandDirection:node_p.algsType delta:delta];
            return (demand == MVDirection_None) ? UIColorWithRGBHex(0x00FF00) : UIColorWithRGBHex(0xFF0000);
        }
    }
    
    //2. HNGLSP节点指定颜色;
    if ([TOUtils isHNGLSP:node_p]) {
        if ([TOUtils isH:node_p]) return ColorH;
        else if ([TOUtils isN:node_p]) return ColorN;
        else if ([TOUtils isG:node_p]) return ColorG;
        else if ([TOUtils isL:node_p]) return ColorL;
        else if ([TOUtils isS:node_p]) return ColorS;
        else if ([TOUtils isP:node_p]) return ColorP;
    }
    
    //2. 坚果显示偏绿色 (抽象黄绿&具象蓝绿)
    if ([NVHeUtil isAlg:node_p]) {
        AIAlgNodeBase *algNode = [SMGUtils searchNode:node_p];
        if (algNode) {
            if ([NVHeUtil isHeight:5 fromContent_ps:algNode.content_ps]) {
                if ([NVHeUtil isAbs:node_p]) {
                    return UIColorWithRGBHex(0xCCFF00);
                }else{
                    return UIColorWithRGBHex(0x00DDFF);
                }
            }
        }
    }

    //3. 抽象显示黄色
    if ([NVHeUtil isAbs:node_p]) {
        return UIColorWithRGBHex(0xFFFF00);
    }
    return nil;
}

-(UIColor *)nv_GetRightColor:(id)nodeData{
    if (PitIsFo(nodeData)) {
        AIFoNodeBase *fo = [SMGUtils searchNode:nodeData];
        CGFloat score = [AIScore score4MV:fo.cmvNode_p ratio:1.0f];
        if (score > 0) {
            return UIColorWithRGBHex(0xAAFFAA);
        }else if(score < 0) {
            return UIColorWithRGBHex(0xFFAAAA);
        }
    }
    return nil;
}

-(CGFloat)nv_GetNodeAlpha:(AIKVPointer*)node_p{
    return 1.0f;
}

-(NSString*)nv_NodeOnClick:(AIKVPointer*)node_p{
    //1. light自己;
    //[theApp.nvView setNodeData:node_p appendLightStr:[NVHeUtil getLightStr:node_p]];
    
    //1. value时,返回 "iden+value值";
    if ([NVHeUtil isValue:node_p]) {
        NSInteger hdRefCount = ARRTOOK([SMGUtils searchObjectForPointer:node_p fileName:kFNRefPorts time:cRTPort]).count;
        NSNumber *value = NUMTOOK([AINetIndex getData:node_p]);
        return STRFORMAT(@"V%ld AT:%@ DS:%@ 值:%@ REF:h%ld",(long)node_p.pointerId,node_p.algsType,node_p.typeStr,value,(long)hdRefCount);
    }
    //2. algNode时,返回content_ps的 "微信息数+嵌套数";
    if([NVHeUtil isAlg:node_p]){
        AIAlgNodeBase *algNode = [SMGUtils searchNode:node_p];
        if (algNode) {
            ///1. 依次点亮content;
            [theNV clearLight:ModuleName_Value];
            for (NSInteger i = 0; i < algNode.content_ps.count; i++) {
                AIKVPointer *item = ARR_INDEX(algNode.content_ps, i);
                [theNV lightNode:item str:[NVHeUtil getLightStr:item]];
            }
            
            ///2. 返回描述;
            NSInteger hdConCount = ISOK(algNode, AIAbsAlgNode.class) ? ((AIAbsAlgNode*)algNode).conPorts.count : 0;
            return STRFORMAT(@"A%ld AT:%@ DS:%@ 数:%ld REF:%lu ABS:%lu CON:%ld 内容:%@",(long)node_p.pointerId,node_p.algsType,node_p.typeStr,(long)algNode.count,(unsigned long)algNode.refPorts.count,(unsigned long)algNode.absPorts.count,(long)hdConCount,Alg2FStr(algNode));
        }
    }
    //3. foNode时,返回 "order_kvp数"
    if([NVHeUtil isFo:node_p]){
        AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
        if (foNode) {
            ///1. 依次点亮orders;
            [theNV clearLight:ModuleName_Alg];
            for (NSInteger i = 0; i < foNode.content_ps.count; i++) {
                AIKVPointer *item = ARR_INDEX(foNode.content_ps, i);
                [theNV lightNode:item str:STRFORMAT(@"%ld%@",(long)i,[TVUtil getLightStr:item])];
            }
            ///2. 返回描述;
            NSInteger hdConCount = ISOK(foNode, AINetAbsFoNode.class) ? ((AINetAbsFoNode*)foNode).conPorts.count : 0;
            return STRFORMAT(@"F%ld AT:%@ DS:%@ 数:%lu ABS:%lu CON:%ld 内容:%@",(long)node_p.pointerId,node_p.algsType,node_p.typeStr,(unsigned long)foNode.content_ps.count,(unsigned long)foNode.absPorts.count,(long)hdConCount,Fo2FStr(foNode));
        }
    }
    //4. mv时,返回 "类型+升降";
    if([NVHeUtil isMv:node_p]){
        AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
        if (mvNode) {
            ///1. 取数据
            NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            NSInteger hdConCount = ISOK(mvNode, AIAbsCMVNode.class) ? ((AIAbsCMVNode*)mvNode).conPorts.count : 0;
            
            ///2. 返回
            return STRFORMAT(@"M%ld iden:%@_%@ urgentTo:%ld delta:%ld ABS:%lu CON:%ld",(long)node_p.pointerId,node_p.algsType,node_p.typeStr,(long)urgentTo,(long)delta,(unsigned long)mvNode.absPorts.count,(long)hdConCount);
        }
    }
    return nil;
}

-(NSArray*)nv_GetModuleIds{
    return @[ModuleName_Value,ModuleName_Alg,ModuleName_Fo,ModuleName_Mv];
}

-(NSString*)nv_GetModuleId:(AIKVPointer*)node_p{
    //判断node_p的类型,并返回;
    if ([NVHeUtil isValue:node_p]) {
        return ModuleName_Value;
    }else if ([NVHeUtil isAlg:node_p]) {
        return ModuleName_Alg;
    }else if ([NVHeUtil isFo:node_p]) {
        return ModuleName_Fo;
    }else if ([NVHeUtil isMv:node_p]) {
        return ModuleName_Mv;
    }
    return nil;
}

-(NSArray*)nv_GetRefNodeDatas:(AIKVPointer*)node_p{
    if (node_p) {
        if ([NVHeUtil isValue:node_p]) {
            NSArray *allPorts = [AINetUtils refPorts_All4Value:node_p];
            return [SMGUtils convertPointersFromPorts:allPorts];
        }else if ([NVHeUtil isAlg:node_p]) {
            //2. 如果是algNode则返回.refPorts;
            AIAlgNodeBase *node = [SMGUtils searchNode:node_p];
            NSArray *allPorts = [AINetUtils refPorts_All4Alg:node];
            return [SMGUtils convertPointersFromPorts:allPorts];
        }else if ([NVHeUtil isFo:node_p]) {
            //3. 如果是foNode则返回mv基本模型指向cmvNode_p;
            AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AIFoNodeBase.class) && foNode.cmvNode_p) {
                return @[foNode.cmvNode_p];
            }
        }else if ([NVHeUtil isMv:node_p]) {
            AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
            NSArray *refPorts = [AINetUtils refPorts_All4Alg:mvNode];
            NSString *nilDesc = @"";
            for (NSInteger i = 0; i < refPorts.count; i++) {
                AIPort *item = ARR_INDEX(refPorts, i);
                if (!item) nilDesc = STRFORMAT(@" %ld",i);
            }
            TPLog(@"> ref条数: %ld 空下标:%@",refPorts.count,nilDesc);
        }
    }
    return nil;
}

-(NSArray*)nv_ContentNodeDatas:(AIKVPointer*)node_p{
    if (node_p) {
        if ([NVHeUtil isAlg:node_p]) {
            //1. algNode时返回content_ps
            AIAlgNodeBase *node = [SMGUtils searchNode:node_p];
            if (ISOK(node, AIAlgNodeBase.class)) {
                return node.content_ps;
            }
        }else if ([NVHeUtil isFo:node_p]) {
            //2. foNode时返回order_kvp
            AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AIFoNodeBase.class)) {
                return foNode.content_ps;
            }
        }else if ([NVHeUtil isMv:node_p]) {
            //3. 如果是mvNode则返回mv指向foNode_p;
            AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
            if (ISOK(mvNode, AICMVNodeBase.class)) {
                return Ports2Pits(ARR_SUB(mvNode.foPorts, 0, 10));
            }
        }
    }
    return nil;
}

-(NSArray*)nv_AbsNodeDatas:(AIKVPointer*)node_p{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (node_p) {
        //1. 如果是algNode/foNode/mvNode则返回.absPorts;
        if ([NVHeUtil isAlg:node_p] || [NVHeUtil isFo:node_p] || [NVHeUtil isMv:node_p]) {

            //3. hdAbsPorts
            AINodeBase *node = [SMGUtils searchNode:node_p];
            if (ISOK(node, AINodeBase.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:node.absPorts]];
            }
        }
    }
    return result;
}

-(NSArray*)nv_ConNodeDatas:(AIKVPointer*)node_p{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (node_p) {
        if ([NVHeUtil isAlg:node_p]) {
            //2. algNode_HdConPorts
            AIAbsAlgNode *absAlgNode = [SMGUtils searchNode:node_p];
            if (ISOK(absAlgNode, AIAbsAlgNode.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:absAlgNode.conPorts]];
            }
        }else if ([NVHeUtil isFo:node_p]) {
            //3. foNode_HdConPorts
            AINetAbsFoNode *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AINetAbsFoNode.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:foNode.conPorts]];
            }
        }else if ([NVHeUtil isMv:node_p]) {
            //4. mvNode_HdConPorts
            AIAbsCMVNode *mvNode = [SMGUtils searchNode:node_p];
            if (ISOK(mvNode, AIAbsCMVNode.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:mvNode.conPorts]];
            }
        }
    }
    return result;
}

//追加节点
-(void)nv_AddNodeOnClick{
    NSArray *subViews = [theApp.window subViews_AllDeepWithClass:CustomAddNodeWindow.class];
    if (ARRISOK(subViews)) {
        for (CustomAddNodeWindow *subView in subViews) {
            [subView removeFromSuperview];
        }
    }else{
        CustomAddNodeWindow *addNodeWindow = [[CustomAddNodeWindow alloc] init];
        [theApp.window addSubview:addNodeWindow];
    }
}

-(NSString*)nv_ShowName:(AIKVPointer*)data_p{
    return STRFORMAT(@"%ld",(long)data_p.pointerId);
}

-(NSInteger)nv_GetPortStrong:(AIKVPointer*)mainNodeData target:(AIKVPointer*)targetNodeData{
    AINodeBase *mainNode = [SMGUtils searchNode:mainNodeData];
    if (mainNode && targetNodeData) {
        //1. 找抽象
        for (AIPort *itemPort in [AINetUtils absPorts_All:mainNode]) {
            if ([itemPort.target_p isEqual:targetNodeData]) {
                return itemPort.strong.value;
            }
        }
        //2. 找具象
        for (AIPort *itemPort in [AINetUtils conPorts_All:mainNode]) {
            if ([itemPort.target_p isEqual:targetNodeData]) {
                return itemPort.strong.value;
            }
        }
        //3. 找被引用
        if (ISOK(mainNode, AIAlgNodeBase.class)) {
            for (AIPort *itemPort in [AINetUtils refPorts_All4Alg:(AIAlgNodeBase*)mainNode]) {
                if ([itemPort.target_p isEqual:targetNodeData]) {
                    return itemPort.strong.value;
                }
            }
        }
    }
    return 0;
}

//方向触发角点击事件;
-(void)nv_DirectionClick:(int)type mView:(NVModuleView*)mView nData:(id)nData targetDatas:(NSArray *)targetDatas{
    //1. 触发角时,显示出关联强度;
    targetDatas = ARRTOOK(targetDatas);
    for (id absData in targetDatas) {
        [theNV lightLineStrong:nData nodeDataB:absData];
    }
}

//方向触发角长按事件;
-(void)nv_LongClick:(int)type mView:(NVModuleView*)mView nData:(id)nData{
    LongTipWindow *window = [[LongTipWindow alloc] init];
    [theApp.window addSubview:window];
    [window setData:mView.moduleId data:nData direction:type];
     
}

@end
