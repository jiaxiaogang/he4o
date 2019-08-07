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

#define ModuleName_Value @"稀疏码"
#define ModuleName_Alg @"概念网络"
#define ModuleName_Fo @"时序网络"
#define ModuleName_Mv @"价值网络"

@implementation NVDelegate_He

/**
 *  MARK:--------------------NVViewDelegate--------------------
 */
- (UIView *)nv_GetCustomSubNodeView:(AIKVPointer*)node_p{
    return nil;
}

-(UIColor *)nv_GetNodeColor:(AIKVPointer*)node_p{
    //1. mv节点:(上升为绿&下降为红)
    if ([self isMv:node_p]) {
        AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
        if (mvNode) {
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            BOOL demand = [ThinkingUtils getDemand:node_p.algsType delta:delta complete:nil];
            return demand ? UIColorWithRGBHex(0xFF0000) : UIColorWithRGBHex(0x00FF00);
        }
    }

    //2. 坚果显示偏绿色 (抽象黄绿&具象蓝绿)
    if ([self isAlg:node_p]) {
        AIAlgNodeBase *algNode = [SMGUtils searchNode:node_p];
        if (algNode) {
            if ([NVHeUtil isHeight:5 fromContent_ps:algNode.content_ps]) {
                if ([self isAbs:node_p]) {
                    return UIColorWithRGBHex(0xCCFF00);
                }else{
                    return UIColorWithRGBHex(0x00DDFF);
                }
            }
        }
    }

    //3. 抽象显示黄色
    if ([self isAbs:node_p]) {
        return UIColorWithRGBHex(0xFFFF00);
    }
    return nil;
}

-(CGFloat)nv_GetNodeAlpha:(AIKVPointer*)node_p{
    if (node_p && node_p.isMem) {
        return 0.5f;
    }
    return 1.0f;
}

-(NSString*)nv_NodeOnClick:(AIKVPointer*)node_p{
    //1. light自己;
    [theNV lightNode:node_p str:[NVHeUtil getLightStr:node_p]];
    
    //1. value时,返回 "iden+value值";
    NSInteger memRefCount = ARRTOOK([SMGUtils searchObjectForPointer:node_p fileName:kFNMemRefPorts time:cRTMemReference]).count;
    if ([self isValue:node_p]) {
        NSInteger hdRefCount = ARRTOOK([SMGUtils searchObjectForPointer:node_p fileName:kFNRefPorts time:cRTReference]).count;
        NSNumber *value = NUMTOOK([AINetIndex getData:node_p]);
        return STRFORMAT(@"pId:%ld,%@,%@:%@ REF:h%ld/m%ld",(long)node_p.pointerId,node_p.algsType,node_p.dataSource,value,(long)hdRefCount,(long)memRefCount);
    }
    //2. algNode时,返回content_ps的 "微信息数+嵌套数";
    NSInteger memAbsCount = ARRTOOK([SMGUtils searchObjectForPointer:node_p fileName:kFNMemAbsPorts time:cRTMemReference]).count;
    NSInteger memConCount = ARRTOOK([SMGUtils searchObjectForPointer:node_p fileName:kFNMemConPorts time:cRTMemReference]).count;
    if([self isAlg:node_p]){
        AIAlgNodeBase *algNode = [SMGUtils searchNode:node_p];
        if (algNode) {
            ///1. 依次点亮content;
            [theNV clearLight:ModuleName_Value];
            for (NSInteger i = 0; i < algNode.content_ps.count; i++) {
                AIKVPointer *item = ARR_INDEX(algNode.content_ps, i);
                [theNV lightNode:item str:[NVHeUtil getLightStr:item]];
            }
            
            ///2. 返回描述;
            NSInteger absAlgCount = 0;
            NSInteger valueCount = 0;
            for (AIKVPointer *value_p in algNode.content_ps) {
                if ([kPN_ALG_ABS_NODE isEqualToString:value_p.folderName]) {
                    absAlgCount++;
                }else{
                    valueCount++;
                }
            }

            NSInteger hdConCount = ISOK(algNode, AIAbsAlgNode.class) ? ((AIAbsAlgNode*)algNode).conPorts.count : 0;
            return STRFORMAT(@"pId:%ld 嵌套数:%ld 微信息数:%ld REF:h%lu/m%ld ABS:h%lu/m%ld CON:h%ld/m%ld",(long)node_p.pointerId,(long)absAlgCount,(long)valueCount,(unsigned long)algNode.refPorts.count,(long)memRefCount,(unsigned long)algNode.absPorts.count,(long)memAbsCount,(long)hdConCount,(long)memConCount);
        }
    }
    //3. foNode时,返回 "order_kvp数"
    if([self isFo:node_p]){
        AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
        if (foNode) {
            ///1. 依次点亮orders;
            [theNV clearLight:ModuleName_Alg];
            for (NSInteger i = 0; i < foNode.orders_kvp.count; i++) {
                AIKVPointer *item = ARR_INDEX(foNode.orders_kvp, i);
                [theNV lightNode:item str:STRFORMAT(@"%ld%@",(long)i,[NVHeUtil getLightStr:item])];
            }
            ///2. 返回描述;
            NSInteger hdConCount = ISOK(foNode, AINetAbsFoNode.class) ? ((AINetAbsFoNode*)foNode).conPorts.count : 0;
            return STRFORMAT(@"pId:%ld 时序数:%d ABS:h%lu/m%ld CON:h%ld/m%ld",(long)node_p.pointerId,foNode.orders_kvp.count,(unsigned long)foNode.absPorts.count,(long)memAbsCount,(long)hdConCount,(long)memConCount);
        }
    }
    //4. mv时,返回 "类型+升降";
    if([self isMv:node_p]){
        AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
        if (mvNode) {
            ///1. 取数据
            NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
            NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
            NSInteger hdConCount = ISOK(mvNode, AIAbsCMVNode.class) ? ((AIAbsCMVNode*)mvNode).conPorts.count : 0;
            
            ///2. 返回
            return STRFORMAT(@"pId:%ld iden:%@_%@ urgentTo:%ld delta:%ld ABS:h%lu/m%ld CON:h%ld/m%ld",(long)node_p.pointerId,node_p.algsType,node_p.dataSource,(long)urgentTo,(long)delta,(unsigned long)mvNode.absPorts.count,(long)memAbsCount,(long)hdConCount,(long)memConCount);
        }
    }
    return nil;
}

-(NSArray*)nv_GetModuleIds{
    return @[ModuleName_Value,ModuleName_Alg,ModuleName_Fo,ModuleName_Mv];
}

-(NSString*)nv_GetModuleId:(AIKVPointer*)node_p{
    //判断node_p的类型,并返回;
    if ([self isValue:node_p]) {
        return ModuleName_Value;
    }else if ([self isAlg:node_p]) {
        return ModuleName_Alg;
    }else if ([self isFo:node_p]) {
        return ModuleName_Fo;
    }else if ([self isMv:node_p]) {
        return ModuleName_Mv;
    }
    return nil;
}

-(NSArray*)nv_GetRefNodeDatas:(AIKVPointer*)node_p{
    if (node_p) {
        if ([self isValue:node_p]) {
            //1. 如果是value,则独立取refPorts文件返回;
            NSMutableArray *result = [[NSMutableArray alloc] init];
            ///1. 取硬盘
            NSArray *hdRefPorts = [SMGUtils searchObjectForFilePath:node_p.filePath fileName:kFNRefPorts time:cRTReference];
            [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:hdRefPorts]];

            ///2. 取内存
            NSArray *memRefPorts = [SMGUtils searchObjectForFilePath:node_p.filePath fileName:kFNMemRefPorts time:cRTMemReference];
            [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:memRefPorts]];
            return result;
        }else if ([self isAlg:node_p]) {
            //2. 如果是algNode则返回.refPorts;
            AIAlgNodeBase *node = [SMGUtils searchNode:node_p];
            if (ISOK(node, AIAlgNodeBase.class)) {
                NSMutableArray *allPorts = [[NSMutableArray alloc] init];
                [allPorts addObjectsFromArray:node.refPorts];
                [allPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:node_p fileName:kFNMemRefPorts time:cRTMemPort]];
                if (allPorts.count == 0) {
                    NSLog(@">>>>>>>> refPorts Hd:%lu Mem:%u",(unsigned long)node.refPorts.count,allPorts.count - node.refPorts.count);
                }
                return [SMGUtils convertPointersFromPorts:allPorts];
            }
        }else if ([self isFo:node_p]) {
            //3. 如果是foNode则返回mv基本模型指向cmvNode_p;
            AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AIFoNodeBase.class) && foNode.cmvNode_p) {
                return @[foNode.cmvNode_p];
            }
        }
    }
    return nil;
}

-(NSArray*)nv_ContentNodeDatas:(AIKVPointer*)node_p{
    if (node_p) {
        if ([self isAlg:node_p]) {
            //1. algNode时返回content_ps
            AIAlgNodeBase *node = [SMGUtils searchNode:node_p];
            if (ISOK(node, AIAlgNodeBase.class)) {
                return node.content_ps;
            }
        }else if ([self isFo:node_p]) {
            //2. foNode时返回order_kvp
            AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AIFoNodeBase.class) && foNode.cmvNode_p) {
                return foNode.orders_kvp;
            }
        }else if ([self isMv:node_p]) {
            //3. 如果是mvNode则返回mv指向foNode_p;
            AICMVNodeBase *mvNode = [SMGUtils searchNode:node_p];
            if (ISOK(mvNode, AICMVNodeBase.class) && mvNode.foNode_p) {
                return @[mvNode.foNode_p];
            }
        }
    }
    return nil;
}

-(NSArray*)nv_AbsNodeDatas:(AIKVPointer*)node_p{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (node_p) {
        //1. 如果是algNode/foNode/mvNode则返回.absPorts;
        if ([self isAlg:node_p] || [self isFo:node_p] || [self isMv:node_p]) {
            //2. memAbsPorts
            NSArray *memAbsPorts = [SMGUtils searchObjectForPointer:node_p fileName:kFNMemAbsPorts];
            [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:memAbsPorts]];

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
        //1. alg&fo&mv_MemConPorts
        if ([self isAlg:node_p] || [self isFo:node_p] || [self isMv:node_p]) {
            NSArray *memConPorts = [SMGUtils searchObjectForPointer:node_p fileName:kFNMemConPorts];
            [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:memConPorts]];
        }

        if ([self isAlg:node_p]) {
            //2. algNode_HdConPorts
            AIAbsAlgNode *absAlgNode = [SMGUtils searchNode:node_p];
            if (ISOK(absAlgNode, AIAbsAlgNode.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:absAlgNode.conPorts]];
            }
        }else if ([self isFo:node_p]) {
            //3. foNode_HdConPorts
            AINetAbsFoNode *foNode = [SMGUtils searchNode:node_p];
            if (ISOK(foNode, AINetAbsFoNode.class)) {
                [result addObjectsFromArray:[SMGUtils convertPointersFromPorts:foNode.conPorts]];
            }
        }else if ([self isMv:node_p]) {
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
    return STRFORMAT(@"%d",data_p.pointerId);
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================
-(BOOL) isValue:(AIKVPointer*)node_p{
    return [kPN_VALUE isEqualToString:node_p.folderName] || [kPN_DATA isEqualToString:node_p.folderName] || [kPN_INDEX isEqualToString:node_p.folderName];
}

-(BOOL) isAlg:(AIKVPointer*)node_p{
    return [kPN_ALG_NODE isEqualToString:node_p.folderName] || [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName];
}

-(BOOL) isFo:(AIKVPointer*)node_p{
    return [kPN_FRONT_ORDER_NODE isEqualToString:node_p.folderName] || [kPN_FO_ABS_NODE isEqualToString:node_p.folderName];
}

-(BOOL) isMv:(AIKVPointer*)node_p{
    return [kPN_CMV_NODE isEqualToString:node_p.folderName] || [kPN_ABS_CMV_NODE isEqualToString:node_p.folderName];
}

-(BOOL) isAbs:(AIKVPointer*)node_p{
    return [kPN_FO_ABS_NODE isEqualToString:node_p.folderName] || [kPN_ABS_CMV_NODE isEqualToString:node_p.folderName] || [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName];
}

@end
