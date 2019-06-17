//
//  NVDelegate_He.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVDelegate_He.h"
#import "AIKVPointer.h"

@implementation NVDelegate_He

/**
 *  MARK:--------------------NVViewDelegate--------------------
 */
- (UIView *)nv_GetCustomNodeView:(AIKVPointer*)node_p{
    return nil;
}

-(NSString*)nv_GetNodeTipsDesc:(AIKVPointer*)node_p{
    //1. value时,返回 "iden+value值";
    //2. algNode时,返回content_ps的 "微信息数+嵌套数";
    //3. foNode时,返回 "order_kvp数"
    //4. mv时,返回 "类型+升降";
    return @"描述还没写";
}

-(NSArray*)nv_GetModuleIds{
    return @[@"微信息",@"概念网络",@"时序网络",@"价值网络"];
}

-(NSString*)nv_GetModuleId:(AIKVPointer*)node_p{
    //判断node_p的类型,并返回;
    NSLog(@"%@",node_p.params);
    if ([kPN_FRONT_ORDER_NODE isEqualToString:node_p.folderName] || [kPN_FO_ABS_NODE isEqualToString:node_p.folderName]) {
        return @"时序网络";
    }else if ([kPN_CMV_NODE isEqualToString:node_p.folderName] || [kPN_ABS_CMV_NODE isEqualToString:node_p.folderName]) {
        return @"价值网络";
    }if ([kPN_ALG_NODE isEqualToString:node_p.folderName] || [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName]) {
        return @"概念网络";
    }if ([kPN_VALUE isEqualToString:node_p.folderName] || [kPN_DATA isEqualToString:node_p.folderName] || [kPN_INDEX isEqualToString:node_p.folderName]) {
        return @"微信息";
    }
    return nil;
}

-(NSArray*)nv_GetRefNodeDatas:(AIKVPointer*)node_p{
    //1. 如果是value,则独立取refPorts文件返回;
    
    //2. 如果是algNode则返回.refPorts;
    
    //3. 如果是foNode/mvNode则返回mv基本模型互指向指针;
    return nil;
}

-(NSArray*)nv_ContentNodeDatas:(AIKVPointer*)node_p{
    //1. value时返回空;
    
    //2. algNode时返回content_ps
    
    //3. foNode时返回order_kvp
    
    //4. mv时返回nil;
    return nil;
}

-(NSArray*)nv_AbsNodeDatas:(AIKVPointer*)node_p{
    //1. 如果是algNode/foNode/mvNode则返回.absPorts;
    //2. 否则返回nil;
    return nil;
}

-(NSArray*)nv_ConNodeDatas:(AIKVPointer*)node_p{
    //1. 如果是algNode/foNode/mvNode则返回.conPorts;
    //2. 否则返回nil;
    return nil;
}

@end
