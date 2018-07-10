//
//  AINetDirectionIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/10.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetDirectionIndex.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIKVPointer.h"

@interface AINetDirectionIndex()

@property (strong, nonatomic) NSMutableArray *positiveDatas;
@property (strong, nonatomic) NSMutableArray *negativeDatas;

@end

@implementation AINetDirectionIndex

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    NSArray *localPositiveDatas = [[PINCache sharedCache] objectForKey:FILENAME_DirectionIndex(MVDirection_Positive)];
    self.positiveDatas = [[NSMutableArray alloc] initWithArray:localPositiveDatas];
    
    NSArray *localNegativeDatas = [[PINCache sharedCache] objectForKey:FILENAME_DirectionIndex(MVDirection_Negative)];
    self.negativeDatas = [[NSMutableArray alloc] initWithArray:localNegativeDatas];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

//给node.pointer建索引
-(AIKVPointer*) setNodePointerToDirectionIndex:(AIKVPointer*)node_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction{
    //1. 数据检查
    if (!ISOK(node_p, AIKVPointer.class)) {
        return nil;
    }
    NSMutableArray *datas = (direction == MVDirection_Negative) ? self.negativeDatas : self.positiveDatas;
    
    //2. 使用二分法查找absValue指针(找到,则返回,找不到,则新建并存储refs_p)
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AINetDirectionIndexModel *checkModel = ARR_INDEX(datas, checkIndex);
        return [XGRedisUtil compareStrA:mvAlgsType strB:checkModel.mvAlgsType];
    } startIndex:0 endIndex:datas.count - 1 success:^(NSInteger index) {
        AINetDirectionIndexModel *checkModel = ARR_INDEX(datas, index);
        resultPointer = checkModel.node_p;
    } failure:^(NSInteger index) {
        AINetDirectionIndexModel *model = [[AINetDirectionIndexModel alloc] init];
        model.node_p = node_p;
        model.mvAlgsType = mvAlgsType;
        if (ARR_INDEXISOK(datas, index)) {
            [datas insertObject:model atIndex:index];
        }else{
            [datas addObject:model];
        }
        resultPointer = node_p;
        //5. 存
        [[PINCache sharedCache] setObject:datas forKey:FILENAME_DirectionIndex(direction)];
    }];
    
    return resultPointer;
}

-(AIKVPointer*) getNodePointerFromDirectionIndex:(NSString*)mvAlgsType direction:(MVDirection)direction{
    //1. 数据
    NSMutableArray *datas = (direction == MVDirection_Negative) ? self.negativeDatas : self.positiveDatas;
    
    //2. 二分法查找
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AINetDirectionIndexModel *checkModel = ARR_INDEX(datas, checkIndex);
        return [XGRedisUtil compareStrA:mvAlgsType strB:checkModel.mvAlgsType];
    } startIndex:0 endIndex:datas.count - 1 success:^(NSInteger index) {
        AINetDirectionIndexModel *checkModel = ARR_INDEX(datas, index);
        resultPointer = checkModel.node_p;
    } failure:^(NSInteger index) {
        NSLog(@"_____未找到相关mv类型的抽象节点地址!!!");
    }];
    
    return resultPointer;
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



//MARK:===============================================================
//MARK:                     < 内存DataSortModel (一组index) >
//MARK:===============================================================
@implementation AINetDirectionIndexModel : NSObject

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.node_p = [aDecoder decodeObjectForKey:@"node_p"];
        self.mvAlgsType = [aDecoder decodeObjectForKey:@"mvAlgsType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.node_p forKey:@"node_p"];
    [aCoder encodeObject:self.mvAlgsType forKey:@"mvAlgsType"];
}

@end
