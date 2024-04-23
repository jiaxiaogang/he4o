//
//  TVUtil_Short.m
//  SMG_NothingIsAll
//
//  Created by jia on 2024.04.05.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import "TVUtil_Short.h"

@implementation TVUtil_Short

+(NSString*) desc4Node:(AINodeBase*)node {
    return [self desc4Pit:node.p];
}

+(NSString*) desc4Pit:(AIKVPointer*)node_p {
    if (ISOK(node_p, AIKVPointer.class)) {
        if (PitIsValue(node_p)) {
            return STRFORMAT(@"V%ld(%@)",node_p.pointerId,[self desc4Value:node_p]);
        }else if (PitIsAlg(node_p)) {
            return STRFORMAT(@"A%ld(%@)",node_p.pointerId,[self desc4Alg:node_p]);
        }else if(PitIsFo(node_p)){
            return STRFORMAT(@"F%ld[%@]",node_p.pointerId,[self desc4Fo:node_p]);
        }else if(PitIsMv(node_p)){
            return STRFORMAT(@"M%ld{%@}",node_p.pointerId,[self desc4Mv:node_p]);
        }
    }
    return @"";
}

+(NSString*) desc4Fo:(AIKVPointer*)fo_p {
    AIAlgNodeBase *fo = [SMGUtils searchNode:fo_p];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    //2. 内容
    for (AIKVPointer *item_p in fo.content_ps){
        if (STRISOK(result)) [result appendString:@","];
        if (PitIsAlg(item_p)) {
            [result appendFormat:@"%@",[self desc4Alg:item_p]];
        } else if (PitIsMv(item_p)) {
            [result appendFormat:@"%@",[self desc4Mv:item_p]];
        }
    }
    return result;
}

+(NSString*) desc4Alg:(AIKVPointer*)alg_p {
    AIAlgNodeBase *alg = [SMGUtils searchNode:alg_p];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    //2. 长度 (只有>1时才显示,像吃,飞,踢这种单特征的就不显示长度了);
    if (alg.count > 1) {
        [result appendFormat:@"%ld",alg.count];
    }
    
    //3. 内容
    for (AIKVPointer *item_p in alg.content_ps){
        [result appendString:[self desc4Value:item_p]];
    }
    return result;
}

+(NSString*) desc4Value:(AIKVPointer*)value_p {
    if (!value_p) return @"";
    double value = [NUMTOOK([AINetIndex getData:value_p]) doubleValue];
    if ([@"sizeHeight" isEqualToString:value_p.dataSource]) {
        if (value == 30) {
            return @"鸟";
        }else if(value == 100) {
            return @"棒";
        }else if(value == 5) {
            return @"果";
        }
    }else if([@"border" isEqualToString:value_p.dataSource]){
        if (value > 0) {
            return @"皮";
        }
    }else if([FLY_RDS isEqualToString:value_p.algsType]){
        return STRFORMAT(@"飞%@",[NVHeUtil fly2Str:value]);
    }else if([KICK_RDS isEqualToString:value_p.algsType]){
        return STRFORMAT(@"踢%@",[NVHeUtil fly2Str:value]);
    }else if([EAT_RDS isEqualToString:value_p.algsType]){
        return @"吃";
    }
    return @"";
}

+(NSString*) desc4Mv:(AIKVPointer*)mv_p {
    CGFloat score = [AIScore score4MV:mv_p ratio:1.0f];
    return STRFORMAT(@"%@%@%@",Mvp2DeltaStr(mv_p),Class2Str(NSClassFromString(mv_p.algsType)),Double2Str_NDZ(score));
}

@end
