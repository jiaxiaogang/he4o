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

/**
 *  MARK:--------------------索引数据分文件--------------------
 *  每个AIPointer只表示一个地址,为了性能优化,pointer指向的数据需要拆分存储;
 *  在索引的存储中,将值与 `第二序列` 分开;(第二序列是索引值的引用节点集合,按强度排序)
 */
//#define FILENAME_Ports @"ports"//目前采用分区的方式,未采用分文件的方式;
#define FILENAME_Reference @"reference"

@implementation AINetIndexReference


-(void) setReference:(AIKVPointer*)indexPointer port:(AIPort*)port difValue:(int)difValue {
    if (ISOK(indexPointer, AIKVPointer.class) && ISOK(port, AIPort.class) && difValue != 0) {
        //1. 取出referenceModel
        NSString *filePath = [indexPointer filePath:PATH_NET_REFERENCE];
        PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
        AINetIndexReferenceModel *referenceModel = [pinCache objectForKey:FILENAME_Reference];
        if (!ISOK(referenceModel, AINetIndexReferenceModel.class)) {
            referenceModel = [[AINetIndexReferenceModel alloc] init];
        }
        
        //2. 二分法查找port,移除旧的;
        __block NSInteger findOldIndex = 0;
        [self search:port from:referenceModel.ports startIndex:0 endIndex:referenceModel.ports.count - 1 success:^(NSInteger index) {
            if (index >= 0 && index < referenceModel.ports.count) {
                [referenceModel.ports removeObjectAtIndex:index];//找到;则移除
            }
            findOldIndex = index;
        } failure:^(NSInteger index) {
            findOldIndex = index;
        }];
        
        //3. 更新strongValue & 插入队列
        BOOL insertDirection = difValue > 0; //是否往后查
        NSInteger insertStartIndex = insertDirection ? findOldIndex : 0;
        NSInteger insertEndIndex = insertDirection ? referenceModel.ports.count - 1 : findOldIndex;
        port.strong.value += difValue;
        [self search:port from:referenceModel.ports startIndex:insertStartIndex endIndex:insertEndIndex success:^(NSInteger index) {
            NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)port.pointer.pointerId);
        } failure:^(NSInteger index) {
            if (referenceModel.ports.count <= index) {
                [referenceModel.ports addObject:port];
            }else{
                [referenceModel.ports insertObject:port atIndex:index];
            }
        }];
        
        //4. 保存队列
        [pinCache setObject:referenceModel forKey:FILENAME_Reference];
    }
}

-(NSArray*) getReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit{
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
 *  MARK:--------------------二分查找--------------------
 *  success:找到则返回相应index
 *  failure:失败则返回可排到的index
 *  要求:ports指向的值是正序的;(即数组下标越大,值越大)
 */
-(void) search:(AIPort*)port from:(NSArray*)ports startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex success:(void(^)(NSInteger index))success failure:(void(^)(NSInteger index))failure{
    if (ISOK(port, AIPort.class) && ARRISOK(ports)) {
        //1. index越界检查
        startIndex = MAX(0, startIndex);
        endIndex = MIN(ports.count - 1, endIndex);
        
        //2. 类比
        typedef void(^ GetDataAndCompareCompletion)(NSComparisonResult compareResult);
        void (^ getDataAndCompare)(NSInteger,GetDataAndCompareCompletion) = ^(NSInteger index,GetDataAndCompareCompletion completion)
        {
            AIPort *checkPort = ARR_INDEX(ports, index);
            NSComparisonResult compareResult = [port compare:checkPort];
            completion(compareResult);
        };
        
        if (labs(startIndex - endIndex) <= 1) {
            //3. 与start对比
            getDataAndCompare(startIndex,^(NSComparisonResult compareResult){
                if (compareResult == NSOrderedDescending) {      //比小的小
                    if (failure) failure(startIndex);
                }else if (compareResult == NSOrderedSame){       //相等
                    if (success) success(startIndex);
                }else {                                         //比小的大
                    if(startIndex == endIndex) {
                        if (failure) failure(startIndex + 1);
                    }else{
                        //4. 与end对比
                        getDataAndCompare(endIndex,^(NSComparisonResult compareResult){
                            if (compareResult == NSOrderedAscending) { //比大的大
                                if (failure) failure(endIndex + 1);
                            }else if (compareResult == NSOrderedSame){ //相等
                                if (success) success(endIndex);
                            }else {                                 //比大的小
                                if (failure) failure(endIndex);
                            }
                        });
                    }
                }
            });
        }else{
            //5. 与mid对比
            NSInteger midIndex = (startIndex + endIndex) / 2;
            getDataAndCompare(midIndex,^(NSComparisonResult compareResult){
                if (compareResult == NSOrderedAscending) { //比中心大(检查mid到endIndex)
                    [self search:port from:ports startIndex:midIndex endIndex:endIndex success:success failure:failure];
                }else if (compareResult == NSOrderedSame){ //相等
                    if (success) success(midIndex);
                }else {                                     //比中心小(检查startIndex到mid)
                    [self search:port from:ports startIndex:startIndex endIndex:midIndex success:success failure:failure];
                }
            });
        }
    }else{
        if (failure) failure(0);
    }
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
