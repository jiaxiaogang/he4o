//
//  AINetIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/4/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetIndex.h"
#import "AIKVPointer.h"
#import "SMGUtils.h"
#import "PINCache.h"
#import "XGRedisUtil.h"

@implementation AINetIndex

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(AIKVPointer*) getDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    //1. 数据准备
    if (!ISOK(data, NSNumber.class)) {
        return nil;
    }
    AIKVPointer *index_p = [SMGUtils createPointerForIndex];
    AIKVPointer *data_p = [SMGUtils createPointerForData:algsType dataSource:dataSource];
    NSMutableArray *indexModels = [[NSMutableArray alloc] initWithArray:ARRTOOK([SMGUtils searchObjectForPointer:index_p fileName:kFNIndex(isOut) time:cRTIndex])];//加载索引序列
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithDictionary:DICTOOK([SMGUtils searchObjectForPointer:data_p fileName:kFNData(isOut) time:cRTData])];//加载微信息值字典(key为pointer.filePath)
    
    //2. 查找model,没则new
    AINetIndexModel *model = nil;
    for (AINetIndexModel *itemModel in indexModels) {
        if ([STRTOOK(algsType) isEqualToString:itemModel.algsType] && [STRTOOK(dataSource) isEqualToString:itemModel.dataSource]) {
            model = itemModel;
            break;
        }
    }
    if (model == nil) {
        model = [[AINetIndexModel alloc] init];
        model.algsType = algsType;
        model.dataSource = dataSource;
        [indexModels addObject:model];
    }
    
    //3. 使用二分法查找data
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSNumber *checkPointerIdNumber = ARR_INDEX(model.pointerIds, checkIndex);
        long checkPointerId = [NUMTOOK(checkPointerIdNumber) longValue];
        AIKVPointer *checkValue_p = [SMGUtils createPointerForValue:checkPointerId algsType:algsType dataSource:dataSource isOut:isOut];
        NSString *key = STRFORMAT(@"%d",checkValue_p.pointerId);
        NSNumber *checkValue = [dataDic objectForKey:key];
        NSComparisonResult compareResult = [NUMTOOK(checkValue) compare:data];
        return compareResult;
    } startIndex:0 endIndex:model.pointerIds.count - 1 success:^(NSInteger index) {
        NSNumber *pointerIdNum = ARR_INDEX(model.pointerIds, index);
        long pointerId = [NUMTOOK(pointerIdNum) longValue];
        AIKVPointer *value_p = [SMGUtils createPointerForValue:pointerId algsType:algsType dataSource:dataSource isOut:isOut];
        resultPointer = value_p;
    } failure:^(NSInteger index) {
        //4. 未找到;创建一个;
        AIKVPointer *value_p = [SMGUtils createPointerForValue:algsType dataSource:dataSource isOut:isOut];
        NSString *key = STRFORMAT(@"%ld",(long)value_p.pointerId);
        [dataDic setObject:data forKey:key];
        resultPointer = value_p;
        
        if (model.pointerIds.count <= index) {
            [model.pointerIds addObject:@(value_p.pointerId)];
        }else{
            [model.pointerIds insertObject:@(value_p.pointerId) atIndex:index];
        }
        
        //5. 存
        [SMGUtils insertObject:indexModels pointer:index_p fileName:kFNIndex(isOut) time:cRTIndex];
        [SMGUtils insertObject:dataDic pointer:data_p fileName:kFNData(isOut) time:cRTData];
    }];
    
    return resultPointer;
}

+(NSNumber*) getData:(AIKVPointer*)value_p{
    AIKVPointer *data_p = [SMGUtils createPointerForData:value_p.algsType dataSource:value_p.dataSource];
    NSDictionary *dataDic = DICTOOK([SMGUtils searchObjectForPointer:data_p fileName:kFNData(value_p.isOut) time:cRTData]);
    NSString *key = STRFORMAT(@"%ld",(long)value_p.pointerId);
    return [dataDic objectForKey:key];
}

//MARK:===============================================================
//MARK:                     < output >
//MARK:===============================================================

//暂时不实现小脑网络;
//-(void) setIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
//    //    [self.outReference setNodePointerToOutputReference:nil algsType:nil dataSource:nil difStrong:0];
//    //    [outReference setReference:indexPointer target_p:target_p difValue:difValue];
//}
//-(NSArray*) getIndexReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit{
//    //    self.outReference getNodePointersFromOutputReference:algsType dataSource:dataSource limit:333333
//    //    return [self.outReference getReference:indexPointer limit:limit];
//    return nil;
//}

@end


//MARK:===============================================================
//MARK:                     < 内存DataSortModel (一组index) >
//MARK:===============================================================
@implementation AINetIndexModel : NSObject

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(NSMutableArray *)pointerIds{
    if (_pointerIds == nil) {
        _pointerIds = [NSMutableArray new];
    }
    return _pointerIds;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointerIds = [aDecoder decodeObjectForKey:@"pointerIds"];
        self.algsType = [aDecoder decodeObjectForKey:@"algsType"];
        self.dataSource = [aDecoder decodeObjectForKey:@"dataSource"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointerIds forKey:@"pointerIds"];
    [aCoder encodeObject:self.algsType forKey:@"algsType"];
    [aCoder encodeObject:self.dataSource forKey:@"dataSource"];
}

@end

