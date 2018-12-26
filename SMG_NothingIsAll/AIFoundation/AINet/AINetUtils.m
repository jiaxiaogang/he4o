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

@implementation AINetUtils

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    return ARRISOK(arr) && [arr containsObject:STRFORMAT(@"%@_%@",algsType,dataSource)];
}


+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime]];
    NSString *identifier = STRFORMAT(@"%@_%@",algsType,dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    }
}


+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找出旧有;
        AIPort *findPort = nil;
        for (AIPort *port in ports) {
            if ([pointer isEqual:port.target_p]) {
                findPort = port;
                break;
            }
        }

        //2. 无则新建port;
        if (!findPort) {
            findPort = [[AIPort alloc] init];
            findPort.target_p = pointer;
        }
        
        //3. 强度更新
        findPort.strong.value ++;
        
        //4. 二分插入
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


@end
