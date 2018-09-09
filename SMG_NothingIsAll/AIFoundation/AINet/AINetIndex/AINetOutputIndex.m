//
//  AINetOutputIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetOutputIndex.h"
#import "AIKVPointer.h"
#import "SMGUtils.h"
#import "PINCache.h"
#import "AIOutputReference.h"
#import "XGRedisUtil.h"
#import "AIOutputKVPointer.h"

@interface AINetOutputIndex ()

@property (strong,nonatomic) NSMutableArray *models;
@property (strong, nonatomic) AIOutputReference *reference;

@end

@implementation AINetOutputIndex

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    NSArray *localModels = [[PINCache sharedCache] objectForKey:FILENAME_OutputIndex];
    self.models = [[NSMutableArray alloc] initWithArray:localModels];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(AIOutputKVPointer*) getDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataTo:(NSString*)dataTo {
    if (!ISOK(data, NSNumber.class)) {
        return nil;
    }
    
    //1. 查找model,没则new
    AINetOutputIndexModel *model = nil;
    for (AINetOutputIndexModel *itemModel in self.models) {
        if ([STRTOOK(algsType) isEqualToString:itemModel.algsType] && [STRTOOK(dataTo) isEqualToString:itemModel.dataTo]) {
            model = itemModel;
            break;
        }
    }
    if (model == nil) {
        model = [[AINetOutputIndexModel alloc] init];
        model.algsType = algsType;
        model.dataTo = dataTo;
        [self.models addObject:model];
    }
    
    //2. 使用二分法查找data
    __block AIOutputKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSNumber *checkPointerIdNumber = ARR_INDEX(model.pointerIds, checkIndex);
        long checkPointerId = [NUMTOOK(checkPointerIdNumber) longValue];
        AIOutputKVPointer *checkOutput_p = [SMGUtils createPointerForOutputValue:checkPointerId algsType:algsType dataTo:dataTo];
        NSNumber *checkValue = [SMGUtils searchObjectForPointer:checkOutput_p fileName:FILENAME_Value time:cRedisValueTime];
        NSComparisonResult compareResult = [NUMTOOK(checkValue) compare:data];
        return compareResult;
    } startIndex:0 endIndex:model.pointerIds.count - 1 success:^(NSInteger index) {
        NSNumber *pointerIdNum = ARR_INDEX(model.pointerIds, index);
        long pointerId = [NUMTOOK(pointerIdNum) longValue];
        AIOutputKVPointer *output_p = [SMGUtils createPointerForOutputValue:pointerId algsType:algsType dataTo:dataTo];
        resultPointer = output_p;
    } failure:^(NSInteger index) {
        //4. 未找到;创建一个;
        AIOutputKVPointer *output_p = [SMGUtils createPointerForOutputValue:algsType dataTo:dataTo];
        [SMGUtils insertObject:data rootPath:output_p.filePath fileName:FILENAME_Value time:cRedisValueTime];
        resultPointer = output_p;
        
        if (model.pointerIds.count <= index) {
            [model.pointerIds addObject:@(output_p.pointerId)];
        }else{
            [model.pointerIds insertObject:@(output_p.pointerId) atIndex:index];
        }
        
        //5. 存
        [[PINCache sharedCache] setObject:self.models forKey:FILENAME_OutputIndex];
    }];
    
    return resultPointer;
}

//MARK:===============================================================
//MARK:                     < itemIndex指向相关 >
//MARK:===============================================================
-(AIOutputReference *)reference{
    if (_reference == nil) {
        _reference = [[AIOutputReference alloc] init];
    }
    return _reference;
}

//暂时不实现小脑网络;
-(void) setIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
//    [self.reference setNodePointerToOutputReference:nil algsType:nil dataTo:nil difStrong:0];
//    [self.reference setReference:indexPointer target_p:target_p difValue:difValue];
}

//暂时不实现小脑网络;
-(NSArray*) getIndexReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit{
//    self.reference getNodePointersFromOutputReference:algsType dataTo:<#(NSString *)#> limit:<#(NSInteger)#>
//    return [self.reference getReference:indexPointer limit:limit];
    return nil;
}

@end



//MARK:===============================================================
//MARK:                     < 内存DataSortModel (一组index) >
//MARK:===============================================================
@implementation AINetOutputIndexModel : NSObject

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
        self.dataTo = [aDecoder decodeObjectForKey:@"dataTo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointerIds forKey:@"pointerIds"];
    [aCoder encodeObject:self.algsType forKey:@"algsType"];
    [aCoder encodeObject:self.dataTo forKey:@"dataTo"];
}

@end

