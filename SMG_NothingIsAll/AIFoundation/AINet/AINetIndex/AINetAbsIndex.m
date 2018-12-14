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
#import "AIAbsManager.h"
#import "AINetIndexReference.h"
#import "AIPort.h"

@interface AINetAbsIndex()

@property (strong, nonatomic) AINetIndexReference *reference;
@property (strong, nonatomic) NSMutableArray *models;//元素:(指针)  有序:(按指针数组排序)

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
    NSArray *localModels = [[PINCache sharedCache] objectForKey:FILENAME_AbsIndex];
    self.models = [[NSMutableArray alloc] initWithArray:localModels];
}
     
//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(AIKVPointer*) getAbsValuePointer:(NSArray*)refs_p {
    //1. 数据检查
    if (!ARRISOK(refs_p)) {
        return nil;
    }
    
    //2. 拼接key
    NSString *key = [self getKey:refs_p];
    
    //3. 使用二分法查找absValue指针(找到,则返回,找不到,则新建并存储refs_p)
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSNumber *checkNum = ARR_INDEX(self.models, checkIndex);
        NSInteger checkPointerId = [NUMTOOK(checkNum) integerValue];
        AIKVPointer *checkValue_p = [SMGUtils createPointerForAbsValue:key pointerId:checkPointerId];
        NSArray *checkRefs_p = [SMGUtils searchObjectForPointer:checkValue_p fileName:FILENAME_AbsValue];
        return [SMGUtils compareRefsA_p:refs_p refsB_p:checkRefs_p];
    } startIndex:0 endIndex:self.models.count - 1 success:^(NSInteger index) {
        NSNumber *num = ARR_INDEX(self.models, index);
        NSInteger pId = [NUMTOOK(num) integerValue];
        resultPointer = [SMGUtils createPointerForAbsValue:key pointerId:pId];
    } failure:^(NSInteger index) {
        AIKVPointer *kvPointer = [SMGUtils createPointerForAbsValue:key];
        PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:kvPointer.filePath];
        [pinCache setObject:refs_p forKey:FILENAME_AbsValue];
        resultPointer = kvPointer;
        
        if (ARR_INDEXISOK(self.models, index)) {
            [self.models insertObject:@(kvPointer.pointerId) atIndex:index];
        }else{
            [self.models addObject:@(kvPointer.pointerId)];
        }
        
        //5. 存
        [[PINCache sharedCache] setObject:self.models forKey:FILENAME_AbsIndex];
    }];
    
    return resultPointer;
}

-(AINetIndexReference *)reference{
    if (_reference == nil) {
        _reference = [[AINetIndexReference alloc] init];
    }
    return _reference;
}


/**
 *  MARK:--------------------根据absValuePointer操作其被引用的相关;--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxAbsNode.pointer)
 */
-(void) setIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.reference setReference:indexPointer target_p:target_p difStrong:difValue];
}


/**
 *  MARK:--------------------获取absValue所被引用的absNode地址;--------------------
 */
-(AIPointer*) getAbsNodePointer:(AIKVPointer*)absValue_p{
    NSArray *ports = [self.reference getReference_JustAbsResult:absValue_p limit:1];
    AIPort *port = ARR_INDEX(ports, 0);
    if (ISOK(port, AIPort.class)) {
        return port.target_p;
    }
    return nil;
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
        [mStr appendFormat:@"%d",p.isOut];
    }
    return mStr;
}

@end
