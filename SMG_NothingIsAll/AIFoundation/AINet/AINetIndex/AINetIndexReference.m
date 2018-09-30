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
#import "PINCache.h"
#import "AIPort.h"
#import "SMGUtils.h"
#import "XGRedisUtil.h"

/**
 *  MARK:--------------------索引数据分文件--------------------
 *  每个AIPointer只表示一个地址,为了性能优化,pointer指向的数据需要拆分存储;
 *  在索引的存储中,将值与 `第二序列` 分开;(第二序列是索引值的引用节点集合,按强度排序)
 */
@implementation AINetIndexReference

/**
 *  MARK:--------------------根据absValuePointer操作其被引用的相关;--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxNode.pointer)
 */
-(void) setReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue {
    if (ISOK(indexPointer, AIKVPointer.class) && ISOK(target_p, AIKVPointer.class) && difValue != 0) {
        NSLog(@"> %@ 引用: %@",target_p.folderName,indexPointer.folderName);
        //1. 取出referenceModel
        NSString *filePath = [indexPointer filePath:PATH_NET_REFERENCE];
        PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
        NSArray *localPorts = [pinCache objectForKey:FILENAME_Reference];
        NSMutableArray *mPorts = [[NSMutableArray alloc] initWithArray:localPorts];
        
        //2. 二分法查找target_p
        __block NSInteger findOldIndex = 0;
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(mPorts, checkIndex);
            return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
        } startIndex:0 endIndex:mPorts.count - 1 success:^(NSInteger index) {
            findOldIndex = index;
        } failure:^(NSInteger index) {
            findOldIndex = index;
        }];
        
        //3. 找到,则移除旧的
        AIPort *findPort = ARR_INDEX(mPorts, findOldIndex);
        if (ARR_INDEXISOK(mPorts, findOldIndex)) {
            [mPorts removeObjectAtIndex:findOldIndex];//找到;则移除
        }
        
        //4. 未找到,则new
        if (!ISOK(findPort, AIPort.class)) {
            findPort = [[AIPort alloc] init];
            findPort.target_p = target_p;
        } 
        
        //5. 更新strongValue & 插入队列
        BOOL insertDirection = difValue > 0; //是否往后查
        NSInteger insertStartIndex = insertDirection ? findOldIndex : 0;
        NSInteger insertEndIndex = insertDirection ? mPorts.count - 1 : findOldIndex;
        findPort.strong.value += difValue;
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(mPorts, checkIndex);
            return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
        } startIndex:insertStartIndex endIndex:insertEndIndex success:^(NSInteger index) {
            NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)findPort.target_p.pointerId);
        } failure:^(NSInteger index) {
            if (mPorts.count <= index) {
                [mPorts addObject:findPort];
            }else{
                [mPorts insertObject:findPort atIndex:index];
            }
        }];
        
        //6. 保存队列
        [pinCache setObject:mPorts forKey:FILENAME_Reference];
    }
}


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
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (ISOK(indexPointer, AIKVPointer.class)) {
        NSString *filePath = [indexPointer filePath:PATH_NET_REFERENCE];
        PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
        NSArray *localPorts = [pinCache objectForKey:FILENAME_Reference];
        localPorts = ARRTOOK(localPorts);
        
        limit = MAX(0, MIN(limit, localPorts.count));
        [mArr addObjectsFromArray:[localPorts subarrayWithRange:NSMakeRange(localPorts.count - limit, limit)]];
    }
    return mArr;
}


/**
 *  MARK:--------------------获取value被引用的absNode地址;--------------------
 *  @param absValue_p : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *  @desc : 1.当indexPointer为absValue时,则只有absNode会被搜索到;
 */
-(NSArray*) getReference_JustAbsResult:(AIKVPointer*)absValue_p limit:(NSInteger)limit {
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (ISOK(absValue_p, AIKVPointer.class) && [PATH_NET_ABSVALUE isEqualToString:absValue_p.folderName]) {
        NSString *filePath = [absValue_p filePath:PATH_NET_REFERENCE];
        PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
        NSArray *localPorts = [pinCache objectForKey:FILENAME_Reference];
        localPorts = ARRTOOK(localPorts);
    
        for (NSInteger i = 0; i < localPorts.count; i++) {
            AIPort *item = ARR_INDEX(localPorts, localPorts.count - i - 1);
            if (item && item.target_p && [PATH_NET_ABS_NODE isEqualToString:[item.target_p paramForKey:@"folderName"]]) {
                [mArr addObject:item];
                if (mArr.count >= limit) {
                    return mArr;
                }
            }
        }
    }
    return mArr;
}


//MARK:===============================================================
//MARK:                     < output >
//MARK:===============================================================

-(void) setNodePointerToOutputReference:(AIKVPointer*)outputNode_p algsType:(NSString*)algsType dataSource:(NSString*)dataSource difStrong:(NSInteger)difStrong{
    //1. 数据检查
    if (!ISOK(outputNode_p, AIKVPointer.class)) {
        return;
    }
    
    //2. 取identifier分区的引用序列文件;
    AIKVPointer *reference_p = [SMGUtils createPointerForOutputReference:algsType dataSource:dataSource];
    NSMutableArray *mArrByPointer = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime]];
    NSMutableArray *mArrByPort = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime]];
    
    //3. 找到旧的mArrByPointer;
    __block AIPort *oldPort = nil;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(mArrByPointer, checkIndex);
        return [SMGUtils comparePointerA:outputNode_p pointerB:checkPort.target_p];
    } startIndex:0 endIndex:mArrByPointer.count - 1 success:^(NSInteger index) {
        AIPort *findPort = ARR_INDEX(mArrByPointer, index);
        if (ISOK(findPort, AIPort.class)) {
            oldPort = findPort;
        }
    } failure:^(NSInteger index) {
        oldPort = [[AIPort alloc] init];
        oldPort.target_p = outputNode_p;
        oldPort.strong.value = 1;
        if (ARR_INDEXISOK(mArrByPointer, index)) {
            [mArrByPointer insertObject:oldPort atIndex:index];
        }else{
            [mArrByPointer addObject:oldPort];
        }
        [SMGUtils insertObject:mArrByPointer rootPath:reference_p.filePath fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime];
    }];
    
    //4. 搜索旧port并去掉_mArrByPort;
    if (oldPort == nil) {
        NSLog(@"BUG!!!未找到,也未生成新的oldPort!!!");
        return;
    }
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
        return [SMGUtils comparePortA:oldPort portB:checkPort];
    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
        AIPort *findPort = ARR_INDEX(mArrByPort, index);
        if (ISOK(findPort, AIPort.class)) {
            [mArrByPort removeObjectAtIndex:index];
        }
    } failure:nil];
    
    //5. 生成新port
    oldPort.strong.value += difStrong;
    AIPort *newPort = oldPort;
    
    //6. 将新port插入_mArrByPort
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
        return [SMGUtils comparePortA:newPort portB:checkPort];
    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
        NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)newPort.target_p.pointerId);
    } failure:^(NSInteger index) {
        if (ARR_INDEXISOK(mArrByPort, index)) {
            [mArrByPort insertObject:newPort atIndex:index];
        }else{
            [mArrByPort addObject:newPort];
        }
        [SMGUtils insertObject:mArrByPort rootPath:reference_p.filePath fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime];
    }];
}


-(NSArray*) getNodePointersFromOutputReference:(NSString*)algsType dataSource:(NSString*)dataSource limit:(NSInteger)limit{
    //1. 取mv分区的引用序列文件;
    AIKVPointer *reference_p = [SMGUtils createPointerForOutputReference:algsType dataSource:dataSource];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPort time:cRedisReferenceTime]];
    
    //2. 根据limit返回limit个结果;
    if (ARRISOK(mArr)) {
        limit = MAX(0, MIN(limit, mArr.count));
        return [mArr subarrayWithRange:NSMakeRange(mArr.count - limit, limit)];
    }
    return nil;
}

@end
