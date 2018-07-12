//
//  AINetDirectionReference.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetDirectionReference.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIKVPointer.h"
#import "AIPort.h"

@implementation AINetDirectionReference

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

-(void) setNodePointerToDirectionReference:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(int)difStrong{
    //1. 数据检查
    if (!ISOK(cmvNode_p, AIKVPointer.class)) {
        return;
    }

    //2. 取mv分区的引用序列文件;
    AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:mvAlgsType direction:direction];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:mvReference_p fileName:FILENAME_Reference time:300]];
    
    //3. 移除旧的
    __block int oldStrong = 0;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(mArr, checkIndex);
        return [SMGUtils comparePointerA:cmvNode_p pointerB:checkPort.target_p];
    } startIndex:0 endIndex:mArr.count - 1 success:^(NSInteger index) {
        AIPort *findPort = ARR_INDEX(mArr, index);
        if (ISOK(findPort, AIPort.class)) {
            [mArr removeObjectAtIndex:index];//找到;则移除
            oldStrong = findPort.strong.value;
        }
    } failure:nil];
    
    //4. 生成新port
    AIPort *newPort = [[AIPort alloc] init];
    newPort.target_p = cmvNode_p;
    newPort.strong.value = oldStrong + difStrong;
    
    //3. 将新port插入到引用序列的合适位置;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(mArr, checkIndex);
        return [SMGUtils comparePortA:newPort portB:checkPort];
    } startIndex:0 endIndex:mArr.count - 1 success:^(NSInteger index) {
        NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)newPort.target_p.pointerId);
    } failure:^(NSInteger index) {
        if (ARR_INDEXISOK(mArr, index)) {
            [mArr insertObject:newPort atIndex:index];
        }else{
            [mArr addObject:newPort];
        }
    }];
    
    //4. 存
    [SMGUtils insertObject:mArr rootPath:mvReference_p.filePath fileName:FILENAME_Reference time:300];
}

-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(NSInteger)limit{
    //1. 取mv分区的引用序列文件;
    AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:mvAlgsType direction:direction];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:mvReference_p fileName:FILENAME_Reference time:300]];
    
    //2. 根据limit返回limit个结果;
    if (ARRISOK(mArr)) {
        limit = MAX(0, MIN(limit, mArr.count));
        return [mArr subarrayWithRange:NSMakeRange(mArr.count - limit, limit)];
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

//根据algsType&dataSource&direction拼接成key
-(NSString*) getKey:(AIKVPointer*)node_p{
    NSMutableString *mStr = [[NSMutableString alloc] init];
    if (ISOK(node_p, AIKVPointer.class)) {
        [mStr appendString:node_p.algsType];
        [mStr appendString:node_p.dataSource];
    }
    return mStr;
}

@end
