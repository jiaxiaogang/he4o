//
//  AINetCMVIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetCMVIndex.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIKVPointer.h"
#import "AIPort.h"

@interface AINetCMVIndex()

@property (strong, nonatomic) NSMutableArray *positiveDatas;
@property (strong, nonatomic) NSMutableArray *negativeDatas;

@end

@implementation AINetCMVIndex

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

-(AIKVPointer*) setNodePointerToDirectionIndex:(AIKVPointer*)cmvNode_p strongValue:(int)strongValue mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction{
    if (!ISOK(cmvNode_p, AIKVPointer.class)) {
        return nil;
    }
    AIPort *port = [[AIPort alloc] init];
    port.pointer = cmvNode_p;
    port.strong.value = strongValue;
    return [self setNodePointerToDirectionIndex:port mvAlgsType:mvAlgsType direction:direction];
}

-(AIKVPointer*) setNodePointerToDirectionIndex:(AIPort*)cmvNodePort mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction{
    //1. 数据检查
    if (!ISOK(cmvNodePort, AIPort.class)) {
        return nil;
    }
    NSMutableArray *datas = (direction == MVDirection_Negative) ? self.negativeDatas : self.positiveDatas;
    
    //2. 使用二分法查找mvAlgsType对应的AINetCMVIndexModel;
    __block AINetCMVIndexModel *findModel;
    __block BOOL needSave = false;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AINetCMVIndexModel *checkModel = ARR_INDEX(datas, checkIndex);
        return [XGRedisUtil compareStrA:mvAlgsType strB:checkModel.algsType];//此处假设cmv无dataSource区分,如果有,则是bug;再改进;...//xxx
    } startIndex:0 endIndex:datas.count - 1 success:^(NSInteger index) {
        AINetCMVIndexModel *checkModel = ARR_INDEX(datas, index);
        findModel = checkModel;
    } failure:^(NSInteger index) {
        AINetCMVIndexModel *model = [[AINetCMVIndexModel alloc] init];
        model.algsType = mvAlgsType;
        if (ARR_INDEXISOK(datas, index)) {
            [datas insertObject:model atIndex:index];
        }else{
            [datas addObject:model];
        }
        findModel = model;
        //5. 存
        needSave = true;
    }];
    
    //3. 将cmvNode_p插入到findModel.pointerIds的合适位置;
    if (!ISOK(findModel, AINetCMVIndexModel.class)) {
        return nil;
    }
    __block AIPort *resultPort = nil;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AIPort *checkPort = ARR_INDEX(findModel.referencePorts, checkIndex);
        return [SMGUtils comparePortA:cmvNodePort portB:checkPort];
    } startIndex:0 endIndex:findModel.referencePorts.count - 1 success:^(NSInteger index) {
        resultPort = ARR_INDEX(findModel.referencePorts, index);
    } failure:^(NSInteger index) {
        if (ARR_INDEXISOK(findModel.referencePorts, index)) {
            [findModel.referencePorts insertObject:cmvNodePort atIndex:index];
        }else{
            [findModel.referencePorts addObject:cmvNodePort];
        }
        resultPort = cmvNodePort;
        needSave = true;
    }];
    
    //4. 存
    if (needSave) {
        [[PINCache sharedCache] setObject:datas forKey:FILENAME_DirectionIndex(direction)];
    }
    
    if (resultPort) {
        return resultPort.pointer;
    }
    return nil;
}

-(AIKVPointer*) getNodePointerFromDirectionIndex:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(NSInteger)limit{
    //1. 数据
    NSMutableArray *datas = (direction == MVDirection_Negative) ? self.negativeDatas : self.positiveDatas;
    
    //2. 二分法查找
    __block AIKVPointer *resultPointer;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        AINetCMVIndexModel *checkModel = ARR_INDEX(datas, checkIndex);
        
        
        
        ////////////////////明日继续.....
        
        
        
        
        return [XGRedisUtil compareStrA:mvAlgsType strB:checkModel.mvAlgsType];
    } startIndex:0 endIndex:datas.count - 1 success:^(NSInteger index) {
        AINetCMVIndexModel *checkModel = ARR_INDEX(datas, index);
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
//MARK:                     < AINetCMVIndexModel (一组index) >
//MARK:===============================================================
@implementation AINetCMVIndexModel : NSObject

- (NSMutableArray *)referencePorts{
    if (_referencePorts == nil) {
        _referencePorts = [NSMutableArray new];
    }
    return _referencePorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.referencePorts = [aDecoder decodeObjectForKey:@"referencePorts"];
        self.algsType = [aDecoder decodeObjectForKey:@"algsType"];
        self.dataSource = [aDecoder decodeObjectForKey:@"dataSource"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.referencePorts forKey:@"referencePorts"];
    [aCoder encodeObject:self.algsType forKey:@"algsType"];
    [aCoder encodeObject:self.dataSource forKey:@"dataSource"];
}

@end
