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
//MARK:                     < insertPointer >
//MARK:===============================================================

+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
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

+(void) insertPointer:(AIPointer*)pointer toMemPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps{
    //1. 找出/生成port
    AIPort *findPort = [self findPort:pointer toPorts:memPorts ps:ps];
    if (findPort) {
        //2. 插到第一个
        [memPorts insertObject:findPort atIndex:0];
    }
}

-(void) insertPointer:(AIKVPointer*)node_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong pointerFileName:(NSString*)pointerFileName portFileName:(NSString*)portFileName{
//    //1. 数据检查
//    if (!ISOK(target_p, AIKVPointer.class) || !ISOK(node_p, AIKVPointer.class) || difStrong == 0) {
//        return;
//    }
//
//    //2. 取identifier分区的引用序列文件;
//    NSMutableArray *mArrByPointer = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:pointerFileName time:cRedisPortTime]];
//    NSMutableArray *mArrByPort = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:portFileName time:cRedisPortTime]];
//
//    //3. 找到旧的mArrByPointer;
//    __block AIPort *oldPort = nil;
//    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
//        AIPort *checkPort = ARR_INDEX(mArrByPointer, checkIndex);
//        return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
//    } startIndex:0 endIndex:mArrByPointer.count - 1 success:^(NSInteger index) {
//        AIPort *findPort = ARR_INDEX(mArrByPointer, index);
//        if (ISOK(findPort, AIPort.class)) {
//            oldPort = findPort;
//        }
//    } failure:^(NSInteger index) {
//        oldPort = [[AIPort alloc] init];
//        oldPort.target_p = target_p;
//        oldPort.strong.value = 1;
//        if (ARR_INDEXISOK(mArrByPointer, index)) {
//            [mArrByPointer insertObject:oldPort atIndex:index];
//        }else{
//            [mArrByPointer addObject:oldPort];
//        }
//        [SMGUtils insertObject:mArrByPointer rootPath:filePath fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime];
//    }];
//
//    //4. 搜索旧port并去掉_mArrByPort;
//    if (oldPort == nil) {
//        NSLog(@"BUG!!!未找到,也未生成新的oldPort!!!");
//        return;
//    }
//    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
//        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
//        return [SMGUtils comparePortA:oldPort portB:checkPort];
//    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
//        AIPort *findPort = ARR_INDEX(mArrByPort, index);
//        if (ISOK(findPort, AIPort.class)) {
//            [mArrByPort removeObjectAtIndex:index];
//        }
//    } failure:nil];
//
//    //5. 生成新port
//    oldPort.strong.value += difStrong;
//    AIPort *newPort = oldPort;
//
//    //6. 将新port插入_mArrByPort
//    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
//        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
//        return [SMGUtils comparePortA:newPort portB:checkPort];
//    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
//        NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)newPort.target_p.pointerId);
//    } failure:^(NSInteger index) {
//        if (ARR_INDEXISOK(mArrByPort, index)) {
//            [mArrByPort insertObject:newPort atIndex:index];
//        }else{
//            [mArrByPort addObject:newPort];
//        }
//        [SMGUtils insertObject:mArrByPort rootPath:filePath fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime];
//    }];
}

+(void) insertPointer:(AIPointer*)algNode_p toRefPortsByValues:(NSArray*)value_ps ps:(NSArray*)ps saveDB:(BOOL)saveDB{
    //1. 遍历value_p微信息,添加引用;
    for (AIPointer *value_p in ARRTOOK(value_ps)) {
        if (ISOK(value_p, AIKVPointer.class)) {
            AIKVPointer *value_kvp = (AIKVPointer*)value_p;
            if ([PATH_NET_ALG_ABS_NODE isEqualToString:value_kvp.folderName]) {
                NSLog(@"______ERROR!!!!此处需要将algNode.refPorts改为独立文件形式存储!!!");
            }
        }
        
        //2. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
        if (saveDB) {
            NSMutableArray *refPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime]];
            [AINetUtils insertPointer:algNode_p toPorts:refPorts ps:ps];
            [SMGUtils insertObject:refPorts rootPath:value_p.filePath fileName:FILENAME_RefPorts time:cRedisReferenceTime saveDB:true];
        }else{
            //3. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
            NSMutableArray *memRefPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:value_p fileName:FILENAME_MemRefPorts]];
            [AINetUtils insertPointer:value_p toMemPorts:memRefPorts ps:ps];
            [SMGUtils insertObject:memRefPorts rootPath:value_p.filePath fileName:FILENAME_MemRefPorts time:cRedisMemOrderTime saveDB:false];//存储
        }
    }
}

+(void) insertPointer:(AIPointer*)foNode_p toRefPortsByOrders:(NSArray*)order_ps ps:(NSArray*)ps{
    for (AIPointer *order_p in ARRTOOK(order_ps)) {
        AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:FILENAME_Node time:cRedisNodeTime];
        if (ISOK(algNode, AIAlgNodeBase.class)) {
            [AINetUtils insertPointer:foNode_p toPorts:algNode.refPorts ps:ps];
            [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];
        }
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

+(void) relateAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes saveDB:(BOOL)saveDB{
    if (ISOK(absNode, AIAbsAlgNode.class) && ARRISOK(conNodes)) {
        //1. 具象节点的 关联&存储
        for (AIAlgNodeBase *conNode in conNodes) {
            if (saveDB) {
                [AINetUtils insertPointer:absNode.pointer toPorts:conNode.absPorts ps:absNode.content_ps];//具象节点插"抽象端口";
                [AINetUtils insertPointer:conNode.pointer toPorts:absNode.conPorts ps:conNode.content_ps];//抽象节点插"具象端口";
                [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:FILENAME_Node time:cRedisNodeTime saveDB:true];//存储
            }else{
                //具象节点插"抽象端口";
                NSMutableArray *memAbsPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:conNode.pointer fileName:FILENAME_MemAbsPorts]];
                [AINetUtils insertPointer:absNode.pointer toMemPorts:memAbsPorts ps:absNode.content_ps];
                [SMGUtils insertObject:memAbsPorts rootPath:conNode.pointer.filePath fileName:FILENAME_MemAbsPorts time:cRedisMemOrderTime saveDB:false];//存储
                
                //抽象节点插"具象端口";
                NSMutableArray *memConPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:conNode.pointer fileName:FILENAME_MemConPorts]];
                [AINetUtils insertPointer:conNode.pointer toMemPorts:memConPorts ps:conNode.content_ps];
                [SMGUtils insertObject:memConPorts rootPath:conNode.pointer.filePath fileName:FILENAME_MemConPorts time:cRedisMemOrderTime saveDB:false];//存储
                
                //TODOTOMORROW:
                //继续写意识流双序列:
                //有三处"//xxxx",可以采用意识流双序列方式;
                
                
                
            }
        }
        
        //2. 抽象节点的 关联&存储
        [SMGUtils insertObject:absNode pointer:absNode.pointer fileName:FILENAME_Node time:cRedisNodeTime_All(saveDB) saveDB:saveDB];
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
