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

@interface AINetIndex ()

@property (strong,nonatomic) NSMutableArray *inModels;
@property (strong,nonatomic) NSMutableArray *outModels;
@property (strong, nonatomic) NSMutableDictionary *inDataDic;
@property (strong, nonatomic) NSMutableDictionary *outDataDic;

@end

@implementation AINetIndex

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
    //TODOTOMORROW:
    //1. 将此处inModels等,直接放redis中,而不是在这儿独立的字段;
    //2. 将所有调用Value的,都取[dic objectForKey:data_p];
    
    
    
    
    //1. 加载索引序列
    self.inModels = [[NSMutableArray alloc] initWithArray:ARRTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForIndex] fileName:FILENAME_Index(false)])];
    self.outModels = [[NSMutableArray alloc] initWithArray:ARRTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForIndex] fileName:FILENAME_Index(true)])];
    
    //2. 加载微信息值字典
    self.inDataDic = [[NSMutableDictionary alloc] initWithDictionary:DICTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForData] fileName:FILENAME_Data(false)])];
    self.outDataDic = [[NSMutableDictionary alloc] initWithDictionary:DICTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForData] fileName:FILENAME_Data(true)])];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(AIKVPointer*) getDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    if (!ISOK(data, NSNumber.class)) {
        return nil;
    }
    
    //1. 查找model,没则new
    AINetIndexModel *model = nil;
    NSMutableArray *models = [self getIndexModels:isOut];
    for (AINetIndexModel *itemModel in models) {
        if ([STRTOOK(algsType) isEqualToString:itemModel.algsType] && [STRTOOK(dataSource) isEqualToString:itemModel.dataSource]) {
            model = itemModel;
            break;
        }
    }
    if (model == nil) {
        model = [[AINetIndexModel alloc] init];
        model.algsType = algsType;
        model.dataSource = dataSource;
        [models addObject:model];
    }
    
    //2. 取dataDic
    NSMutableDictionary *dataDic = [self getDataDic:isOut];
    
    //3. 使用二分法查找data
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSNumber *checkPointerIdNumber = ARR_INDEX(model.pointerIds, checkIndex);
        long checkPointerId = [NUMTOOK(checkPointerIdNumber) longValue];
        AIKVPointer *checkValue_p = [SMGUtils createPointerForValue:checkPointerId algsType:algsType dataSource:dataSource isOut:isOut];
        NSNumber *checkValue = [dataDic objectForKey:checkValue_p];
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
        [dataDic setObject:data forKey:value_p];
        resultPointer = value_p;
        
        if (model.pointerIds.count <= index) {
            [model.pointerIds addObject:@(value_p.pointerId)];
        }else{
            [model.pointerIds insertObject:@(value_p.pointerId) atIndex:index];
        }
        
        //5. 存
        [SMGUtils insertObject:models rootPath:[SMGUtils createPointerForIndex].filePath fileName:FILENAME_Index(isOut)];
        [SMGUtils insertObject:dataDic rootPath:[SMGUtils createPointerForData].filePath fileName:FILENAME_Data(isOut)];
    }];
    
    return resultPointer;
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

//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================
-(NSMutableArray*) getIndexModels:(BOOL)isOut{
    return isOut ? self.outModels : self.inModels;
}

/**
 *  MARK:--------------------取微信息值字典--------------------
 *  @result notnull
 */
-(NSMutableDictionary*) getDataDic:(BOOL)isOut{
    return isOut ? self.outDataDic : self.inDataDic;
}

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

