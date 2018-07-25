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
//#define FILENAME_Ports @"ports"//目前采用分区的方式,未采用分文件的方式;


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
        AINetIndexReferenceModel *referenceModel = [pinCache objectForKey:FILENAME_Reference];
        if (!ISOK(referenceModel, AINetIndexReferenceModel.class)) {
            referenceModel = [[AINetIndexReferenceModel alloc] init];
        }
        
        //2. 二分法查找target_p
        __block NSInteger findOldIndex = 0;
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(referenceModel.ports, checkIndex);
            return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
        } startIndex:0 endIndex:referenceModel.ports.count - 1 success:^(NSInteger index) {
            findOldIndex = index;
        } failure:^(NSInteger index) {
            findOldIndex = index;
        }];
        
        //3. 找到,则移除旧的
        AIPort *findPort = ARR_INDEX(referenceModel.ports, findOldIndex);
        if (ARR_INDEXISOK(referenceModel.ports, findOldIndex)) {
            [referenceModel.ports removeObjectAtIndex:findOldIndex];//找到;则移除
        }
        
        //4. 未找到,则new
        if (!ISOK(findPort, AIPort.class)) {
            findPort = [[AIPort alloc] init];
            findPort.target_p = target_p;
        } 
        
        //5. 更新strongValue & 插入队列
        BOOL insertDirection = difValue > 0; //是否往后查
        NSInteger insertStartIndex = insertDirection ? findOldIndex : 0;
        NSInteger insertEndIndex = insertDirection ? referenceModel.ports.count - 1 : findOldIndex;
        findPort.strong.value += difValue;
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(referenceModel.ports, checkIndex);
            return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
        } startIndex:insertStartIndex endIndex:insertEndIndex success:^(NSInteger index) {
            NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)findPort.target_p.pointerId);
        } failure:^(NSInteger index) {
            if (referenceModel.ports.count <= index) {
                [referenceModel.ports addObject:findPort];
            }else{
                [referenceModel.ports insertObject:findPort atIndex:index];
            }
        }];
        
        //6. 保存队列
        [pinCache setObject:referenceModel forKey:FILENAME_Reference];
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
        AINetIndexReferenceModel *referenceModel = [pinCache objectForKey:FILENAME_Reference];
        if (ISOK(referenceModel, AINetIndexReferenceModel.class)) {
            limit = MAX(0, MIN(limit, referenceModel.ports.count));
            [mArr addObjectsFromArray:[referenceModel.ports subarrayWithRange:NSMakeRange(referenceModel.ports.count - limit, limit)]];
        }
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
        AINetIndexReferenceModel *referenceModel = [pinCache objectForKey:FILENAME_Reference];
        if (ISOK(referenceModel, AINetIndexReferenceModel.class)) {
            for (NSInteger i = 0; i < referenceModel.ports.count; i++) {
                AIPort *item = ARR_INDEX(referenceModel.ports, referenceModel.ports.count - i - 1);
                if (item && item.target_p && [PATH_NET_ABSNODE isEqualToString:[item.target_p paramForKey:@"folderName"]]) {
                    [mArr addObject:item];
                    if (mArr.count >= limit) {
                        return mArr;
                    }
                }
            }
        }
    }
    return mArr;
}

@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@implementation AINetIndexReferenceModel : NSObject

-(NSMutableArray *)ports{
    if (_ports == nil) {
        _ports = [[NSMutableArray alloc] init];
    }
    return _ports;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.ports = [aDecoder decodeObjectForKey:@"ports"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ports forKey:@"ports"];
}

@end
