//
//  AINetAbsIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/5.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsIndex.h"
#import "SMGUtils.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "XGRedisUtil.h"
#import "AINetAbs.h"

@interface AINetAbsIndex()

@property (strong, nonatomic) NSMutableDictionary *dic;//key为宏信息的分区标识,value为该分区下的有序指针数组;

@end

@implementation AINetAbsIndex

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    NSDictionary *localDic = [[PINCache sharedCache] objectForKey:FILENAME_AbsIndex];
    self.dic = [[NSMutableDictionary alloc] initWithDictionary:localDic];
}
     
//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

//创建absNode前,要先查是否已存在;
-(AIKVPointer*) getAbsPointer:(NSArray*)refs_p{
    //1. 拼接key
    NSString *key = [self getKey:refs_p];
    
    //2. 二分法查找(从小到大)
    NSArray *indexArr_p = ARRTOOK([self.dic objectForKey:key]);
    __block AIKVPointer *absNode_p = nil;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIKVPointer *check_p = ARR_INDEX(indexArr_p, checkIndex);
        AINetAbsNode *checkAbsNode = [SMGUtils searchObjectForPointer:check_p fileName:FILENAME_Node];
        return [SMGUtils compareRefsA_p:refs_p refsB_p:checkAbsNode.refs_p];
    } startIndex:0 endIndex:indexArr_p.count success:^(NSInteger index) {
        absNode_p = ARR_INDEX(indexArr_p, index);
    } failure:nil];
    
    //3. return
    return absNode_p;
}

//创建absNode后,要建索引;
-(void) setAbsNode:(AINetAbsNode*)absNode{
    //1. 数据检查
    if (!ISOK(absNode, AINetAbsNode.class)) {
        return;
    }
    //2. 拼接key
    NSString *key = [self getKey:absNode.refs_p];
    
    //3. 分区检查
    NSArray *indexArr_p = [self.dic objectForKey:key];
    if (ARRISOK(indexArr_p)) {
        //4. 有分区,则二分法插入;(从小到大)
        __block NSInteger findOldIndex;
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIKVPointer *check_p = ARR_INDEX(indexArr_p, checkIndex);
            AINetAbsNode *checkAbsNode = [SMGUtils searchObjectForPointer:check_p fileName:FILENAME_Node];
            return [SMGUtils compareRefsA_p:absNode.refs_p refsB_p:checkAbsNode.refs_p];
        } startIndex:0 endIndex:indexArr_p.count success:^(NSInteger index) {
            if (ARR_INDEXISOK(absNode.refs_p,index)) {
                [absNode.refs_p removeObjectAtIndex:index];
            }
            findOldIndex = index;
        } failure:^(NSInteger index) {
            findOldIndex = index;
        }];
        
        //5. 插入到index
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:indexArr_p];
        if (ARR_INDEXISOK(mArr, findOldIndex)) {
            [mArr insertObject:absNode.pointer atIndex:findOldIndex];
        }else{
            [mArr addObject:absNode.pointer];
        }
        [self.dic setObject:mArr forKey:key];
    }else{
        //6. 无分区,则创建;
        NSArray *newArr = @[absNode.pointer];
        [self.dic setObject:newArr forKey:key];
    }
    
    //7. 更新存储(后续加异步策略)
    [[PINCache sharedCache] setObject:self.dic forKey:FILENAME_AbsIndex];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

//根据algsType&dataSource拼接成key
-(NSString*) getKey:(NSArray*)refs_p{
    NSMutableString *mStr = [[NSMutableString alloc] init];
    for (AIKVPointer *p in ARRTOOK(refs_p)) {
        [mStr appendString:p.algsType];
        [mStr appendString:p.dataSource];
    }
    return mStr;
}

@end
