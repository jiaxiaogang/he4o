//
//  AIOutputReference.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIOutputReference.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AIKVPointer.h"

@implementation AIOutputReference

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
}

//MARK:===============================================================
//MARK:                     < publicMethod >
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

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource{
    AIKVPointer *reference_p = [SMGUtils createPointerForOutputReference:algsType dataSource:dataSource];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:reference_p fileName:FILENAME_Reference_ByPointer time:cRedisReferenceTime]];
    return ARRISOK(mArr);
}

@end
