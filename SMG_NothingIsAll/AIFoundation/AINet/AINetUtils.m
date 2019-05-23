//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "XGRedisUtil.h"
#import "NSString+Extension.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"

@implementation AINetUtils

//MARK:===============================================================
//MARK:                     < CanOutput >
//MARK:===============================================================

+(BOOL) checkCanOutput:(NSString*)dataSource {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    return ARRISOK(arr) && [arr containsObject:STRTOOK(dataSource)];
}


+(void) setCanOutput:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime]];
    NSString *identifier = STRTOOK(dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime saveDB:true];
    }
}


//MARK:===============================================================
//MARK:                     < 横向refPorts引用-祖母引用微信息 >
//MARK:===============================================================
+(void) insertRefPorts_AllAlgNode:(AIPointer*)algNode_p value_ps:(NSArray*)value_ps ps:(NSArray*)ps{
    //1. 遍历value_p微信息,添加引用;
    for (AIPointer *value_p in ARRTOOK(value_ps)) {
        //2. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
        if (!algNode_p.isMem) {
            NSMutableArray *refPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime]];
            [AINetUtils insertPointer_Hd:algNode_p toPorts:refPorts ps:ps];
            [SMGUtils insertObject:refPorts rootPath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime saveDB:true];
        }else{
            //3. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
            [AINetUtils insertRefPorts_MemNode:algNode_p passiveRef_p:value_p];
        }
    }
}


//MARK:===============================================================
//MARK:                     < 横向refPorts引用-时序引用祖母 >
//MARK:===============================================================
+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps{
    for (AIPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps];
    }
}
+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_p:(AIPointer*)order_p ps:(NSArray*)ps{
    if (!foNode_p.isMem) {
        AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:FILENAME_Node time:cRedisNodeTime];
        if (ISOK(algNode, AIAlgNodeBase.class)) {
            [AINetUtils insertPointer_Hd:foNode_p toPorts:algNode.refPorts ps:ps];
            [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];
        }
    }else{
        [self insertRefPorts_MemNode:foNode_p passiveRef_p:order_p ps:ps];
    }
}


//MARK:===============================================================
//MARK:                     < 内存插线 >
//MARK:===============================================================

+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p{
    [self insertRefPorts_MemNode:memNode_p passiveRef_p:passiveRef_p ps:nil];
}
+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p ps:(NSArray*)ps{
    if (ISOK(memNode_p, AIKVPointer.class) && ISOK(passiveRef_p, AIKVPointer.class)) {
        //1. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
        NSMutableArray *memRefPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:passiveRef_p fileName:FILENAME_MemRefPorts]];
        [AINetUtils insertPointer_Mem:memNode_p toPorts:memRefPorts ps:ps];
        [SMGUtils insertObject:memRefPorts rootPath:passiveRef_p.filePath fileName:FILENAME_MemRefPorts time:cRedisMemNetTime saveDB:false];//存储
    }
}

+(void) insertAbsPorts_MemNode:(AIPointer*)abs_p con_p:(AIPointer*)con_p absNodeContent:(NSArray*)absNodeContent{
    if (ISOK(abs_p, AIKVPointer.class) && ISOK(con_p, AIKVPointer.class)) {
        NSMutableArray *memAbsPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:con_p fileName:FILENAME_MemAbsPorts]];
        [AINetUtils insertPointer_Mem:abs_p toPorts:memAbsPorts ps:absNodeContent];
        [SMGUtils insertObject:memAbsPorts rootPath:con_p.filePath fileName:FILENAME_MemAbsPorts time:cRedisMemPortTime saveDB:false];//存储
    }
}

+(void) insertConPorts_MemNode:(AIPointer*)con_p abs_p:(AIPointer*)abs_p conNodeContent:(NSArray*)conNodeContent{
    if (ISOK(con_p, AIKVPointer.class) && ISOK(abs_p, AIKVPointer.class)) {
        NSMutableArray *memConPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:abs_p fileName:FILENAME_MemConPorts]];
        [AINetUtils insertPointer_Mem:con_p toPorts:memConPorts ps:conNodeContent];
        [SMGUtils insertObject:memConPorts rootPath:abs_p.filePath fileName:FILENAME_MemConPorts time:cRedisMemPortTime saveDB:false];//存储
    }
}


//MARK:===============================================================
//MARK:                     < 仅插线 到 ports >
//MARK:===============================================================

+(void) insertPointer_Hd:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找到/新建port
        AIPort *findPort = [self findPort:pointer toPorts:ports ps:ps];
        if (!findPort) {
            return;
        }
        
        //2. 强度更新
        findPort.strong.value ++;
        
        //3. 二分插入
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(ports, checkIndex);
            return [SMGUtils comparePortA:findPort portB:checkPort];
        } startIndex:0 endIndex:ports.count - 1 success:^(NSInteger index) {
            NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)findPort.target_p.pointerId);
        } failure:^(NSInteger index) {
            if (ARR_INDEXISOK(ports, index)) {
                [ports insertObject:findPort atIndex:index];
            }else{
                [ports addObject:findPort];
            }
        }];
    }
}

+(void) insertPointer_Mem:(AIPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps{
    //1. 找出/生成port
    AIPort *findPort = [self findPort:pointer toPorts:memPorts ps:ps];
    if (findPort) {
        //2. 插到第一个
        [memPorts insertObject:findPort atIndex:0];
    }
}


//MARK:===============================================================
//MARK:                     < Other >
//MARK:===============================================================

+(BOOL) checkAllOfOut:(NSArray*)value_ps{
    if (ARRISOK(value_ps)) {
        for (AIKVPointer *value_p in value_ps) {
            if (!value_p.isOut) {
                return false;
            }
        }
        return true;
    }
    return false;
}

//MARK:===============================================================
//MARK:                     < Relate >
//MARK:===============================================================

+(void) relateAlgAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes{
    if (ISOK(absNode, AIAbsAlgNode.class) && ARRISOK(conNodes)) {
        //1. 具象节点的 关联&存储
        for (AIAlgNodeBase *conNode in conNodes) {
            if (!conNode.pointer.isMem) {
                [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absNode.content_ps];//具象节点插"抽象端口";
                [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absNode.conPorts ps:conNode.content_ps];//抽象节点插"具象端口";
                [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];//存储
            }else{
                [self insertAbsPorts_MemNode:absNode.pointer con_p:conNode.pointer absNodeContent:absNode.content_ps];//抽象插到具象上
                [self insertConPorts_MemNode:conNode.pointer abs_p:absNode.pointer conNodeContent:conNode.content_ps];//具象插到抽象上
            }
        }
        
        //2. 抽象节点的 关联&存储
        [SMGUtils insertObject:absNode pointer:absNode.pointer fileName:FILENAME_Node time:cRedisNodeTime_All(absNode.pointer.isMem)];
    }
}

+(void) relateFoAbs:(AINetAbsFoNode*)absNode conNodes:(NSArray*)conNodes{
    if (ISOK(absNode, AINetAbsFoNode.class) && ARRISOK(conNodes)) {
        //1. 具象节点的 关联&存储
        for (AIFoNodeBase *conNode in conNodes) {
            if (!conNode.pointer.isMem) {
                [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absNode.orders_kvp];//具象节点插"抽象端口";
                [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absNode.conPorts ps:conNode.orders_kvp];//抽象节点插"具象端口";
                [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];//存储
            }else{
                [self insertAbsPorts_MemNode:absNode.pointer con_p:conNode.pointer absNodeContent:absNode.orders_kvp];//抽象插到具象上
                [self insertConPorts_MemNode:conNode.pointer abs_p:absNode.pointer conNodeContent:conNode.orders_kvp];//具象插到抽象上
            }
        }
        
        //2. 抽象节点的 关联&存储
        [SMGUtils insertObject:absNode pointer:absNode.pointer fileName:FILENAME_Node time:cRedisNodeTime_All(absNode.pointer.isMem)];
    }
}

//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------从ports中找出符合的port或者new一个--------------------
 */
+(AIPort*) findPort:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找出旧有;
        AIPort *findPort = nil;
        for (AIPort *port in ports) {
            if ([pointer isEqual:port.target_p]) {
                findPort = port;
                [ports removeObject:port];
                break;
            }
        }
        
        //2. 无则新建port;
        if (!findPort) {
            findPort = [[AIPort alloc] init];
            findPort.target_p = pointer;
            findPort.header = [NSString md5:[SMGUtils convertPointers2String:ps]];
        }
        
        return findPort;
    }
    return nil;
}

@end


///**
// *  MARK:--------------------插线到ports (分文件优化)--------------------
// *  @param pointerFileName : 指针序列文件名,如FILENAME_Reference_ByPointer
// *  @param portFileName : 强度序列文件名,如FILENAME_Reference_ByPort
// *
// *  1. 各种神经元中只保留"指针"和"类型";
// *  2. 其它absPorts,conPorts,refPorts都使用单独文件的方式;
// *  3. 暂不使用 (未完成)
// */
//-(void) insertPointer:(AIKVPointer*)node_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong pointerFileName:(NSString*)pointerFileName portFileName:(NSString*)portFileName{
////    //1. 数据检查
////    if (!ISOK(target_p, AIKVPointer.class) || !ISOK(node_p, AIKVPointer.class) || difStrong == 0) {
////        return;
////    }
////
////    //2. 取identifier分区的引用序列文件;
////    NSMutableArray *mArrByPointer = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:pointerFileName time:cRedisPortTime]];
////    NSMutableArray *mArrByPort = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:portFileName time:cRedisPortTime]];
////
////    //3. 找到旧的mArrByPointer;
////    __block AIPort *oldPort = nil;
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPointer, checkIndex);
////        return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
////    } startIndex:0 endIndex:mArrByPointer.count - 1 success:^(NSInteger index) {
////        AIPort *findPort = ARR_INDEX(mArrByPointer, index);
////        if (ISOK(findPort, AIPort.class)) {
////            oldPort = findPort;
////        }
////    } failure:^(NSInteger index) {
////        oldPort = [[AIPort alloc] init];
////        oldPort.target_p = target_p;
////        oldPort.strong.value = 1;
////        if (ARR_INDEXISOK(mArrByPointer, index)) {
////            [mArrByPointer insertObject:oldPort atIndex:index];
////        }else{
////            [mArrByPointer addObject:oldPort];
////        }
////        [SMGUtils insertObject:mArrByPointer rootPath:filePath fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime];
////    }];
////
////    //4. 搜索旧port并去掉_mArrByPort;
////    if (oldPort == nil) {
////        NSLog(@"BUG!!!未找到,也未生成新的oldPort!!!");
////        return;
////    }
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
////        return [SMGUtils comparePortA:oldPort portB:checkPort];
////    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
////        AIPort *findPort = ARR_INDEX(mArrByPort, index);
////        if (ISOK(findPort, AIPort.class)) {
////            [mArrByPort removeObjectAtIndex:index];
////        }
////    } failure:nil];
////
////    //5. 生成新port
////    oldPort.strong.value += difStrong;
////    AIPort *newPort = oldPort;
////
////    //6. 将新port插入_mArrByPort
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
////        return [SMGUtils comparePortA:newPort portB:checkPort];
////    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
////        NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)newPort.target_p.pointerId);
////    } failure:^(NSInteger index) {
////        if (ARR_INDEXISOK(mArrByPort, index)) {
////            [mArrByPort insertObject:newPort atIndex:index];
////        }else{
////            [mArrByPort addObject:newPort];
////        }
////        [SMGUtils insertObject:mArrByPort rootPath:filePath fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime];
////    }];
//}
