//
//  AINetIndexReference.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetIndexReference.h"
#import "AIPort.h"
#import "AIKVPointer.h"
#import "XGRedisUtil.h"
#import "AINetUtils.h"

/**
 *  MARK:--------------------索引数据分文件--------------------
 *  每个AIPointer只表示一个地址,为了性能优化,pointer指向的数据需要拆分存储;
 *  在索引的存储中,将值与 `第二序列` 分开;(第二序列是索引值的引用节点集合,按强度排序)
 */
@implementation AINetIndexReference

//-(void) setReference:(AIKVPointer*)value_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong {
//    //1. 数据检查
//    if (!ISOK(target_p, AIKVPointer.class) || !ISOK(index_p, AIKVPointer.class) || difStrong == 0) {
//        return;
//    }
//    
//    //2. 取identifier分区的引用序列文件;
//    NSString *filePath = [index_p filePath:kPN_REFERENCE];
//    NSMutableArray *mArrByPointer = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:filePath fileName:kFNReference_ByPointer time:cRTReference]];
//    NSMutableArray *mArrByPort = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:filePath fileName:kFNReference_ByPort time:cRTReference]];
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
//        [SMGUtils insertObject:mArrByPointer rootPath:filePath fileName:kFNReference_ByPointer time:cRTReference saveDB:true];
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
//    //BOOL insertDirection = difValue > 0; //是否往后查
//    //NSInteger insertStartIndex = insertDirection ? findOldIndex : 0;
//    //NSInteger insertEndIndex = insertDirection ? mPorts.count - 1 : findOldIndex;
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
//        [SMGUtils insertObject:mArrByPort rootPath:filePath fileName:kFNReference_ByPort time:cRTReference saveDB:true];
//    }];
//}

/**
 *  MARK:--------------------获取value被引用的node地址;--------------------
 *  @param indexPointer : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *
 *  @desc : 1.当indexPointer为absValue时,则只有absNode和frontNode会被搜索到;
 *  @desc : 2.当indexPointer为普通value时,则有可能搜索到除absNode之外的所有其它node(如:frontNode或mvNode等)
 */
-(NSArray*) getReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit {
    //1. 数据检查
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (ISOK(indexPointer, AIKVPointer.class)) {
        
        //2. 取identifier分区的引用序列文件;
        NSString *filePath = [indexPointer filePath:kPN_REFERENCE];
        NSArray *localPorts = ARRTOOK([SMGUtils searchObjectForFilePath:filePath fileName:kFNReference_ByPort time:cRTReference]);
        
        limit = MAX(0, MIN(limit, localPorts.count));
        [mArr addObjectsFromArray:[localPorts subarrayWithRange:NSMakeRange(localPorts.count - limit, limit)]];
    }
    return mArr;
}

@end
