//
//  AINetIndex.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/4/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetIndex.h"
#import "AIKVPointer.h"
#import "AIModel.h"
#import "SMGUtils.h"

@interface AINetIndex ()

@property (strong,nonatomic) NSMutableArray *models;

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
    self.models = [[NSMutableArray alloc] init];
    //加载本地xxx
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(AIPointer*) getPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource {
    if (!ISOK(data, NSNumber.class)) {
        return nil;
    }
    
    //1. 查找model,没则new
    AINetIndexModel *model = nil;
    for (AINetIndexModel *itemModel in self.models) {
        if ([STRTOOK(algsType) isEqualToString:itemModel.algsType] && [STRTOOK(dataSource) isEqualToString:itemModel.dataSource]) {
            model = itemModel;
            break;
        }
    }
    if (model == nil) {
        model = [[AINetIndexModel alloc] init];
        model.algsType = algsType;
        model.dataSource = dataSource;
    }
    
    //2. 使用二分法查找data
    __block AIPointer *resultPointer;
    [self search:data fromIds:model.pointerIds startIndex:0 endIndex:model.pointerIds.count - 1 success:^(AIPointer *pointer) {
        resultPointer = pointer;
    } failure:^(NSInteger index) {
        NSLog(@"");//根据dT&dS为key有序存到mDic;
        if (model.pointerIds.count <= index) {
            NSInteger pointerId = [SMGUtils createPointerId:algsType dataSource:dataSource];
            AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_INDEX algsType:algsType dataSource:dataSource];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kvPointer.filePath];
            [model.pointerIds addObject:@(pointerId)];
            resultPointer = kvPointer;
        }
    }];
    
    return resultPointer;
}

/**
 *  MARK:--------------------二分查找--------------------
 *  success:找到则返回相应AIPointer
 *  failure:失败则返回data可排到的下标
 *  要求:ids指向的值是正序的;(即数组下标越大,值越大)
 */
-(void) search:(NSNumber*)data fromIds:(NSArray*)ids startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex success:(void(^)(AIPointer *pointer))success failure:(void(^)(NSInteger index))failure{
    if (ARRISOK(ids)) {
        //1. index越界检查
        startIndex = MAX(0, startIndex);
        endIndex = MIN(ids.count - 1, endIndex);
        
        //2. io方法
        typedef void(^ GetDataAndCompareCompletion)(NSComparisonResult result,AIPointer *pointer);
        void (^ getDataAndCompare)(NSInteger,GetDataAndCompareCompletion) = ^(NSInteger index,GetDataAndCompareCompletion completion){
            AIPointer *pointer = ARR_INDEX(ids, index);
            NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:pointer.filePath];
            NSComparisonResult compare = [data compare:value];
            completion(compare,pointer);
        };
        
        if (labs(startIndex - endIndex) <= 1) {
            //3. 与start对比
            AIPointer *startPointer = ARR_INDEX(ids, startIndex);
            NSNumber *startValue = [[NSUserDefaults standardUserDefaults] objectForKey:startPointer.filePath];
            NSComparisonResult compareStart = [data compare:startValue];
            
            getDataAndCompare(startIndex,^(NSComparisonResult result,AIPointer *pointer){
                                  NSLog(@"");
                              }
            );
            
            if (compareStart == NSOrderedDescending) {      //比小的小
                if (failure) failure(startIndex);
            }else if (compareStart == NSOrderedSame){       //相等
                if (success) success(startPointer);
            }else {                                         //比小的大
                if(startIndex == endIndex) {
                    if (failure) failure(startIndex + 1);
                }else{
                    //4. 与end对比
                    AIPointer *endPointer = ARR_INDEX(ids, endIndex);
                    NSNumber *endValue = [[NSUserDefaults standardUserDefaults] objectForKey:endPointer.filePath];
                    NSComparisonResult compareEnd = [data compare:endValue];
                    if (compareEnd == NSOrderedAscending) { //比大的大
                        if (failure) failure(endIndex + 1);
                    }else if (compareEnd == NSOrderedSame){ //相等
                        if (success) success(endPointer);
                    }else {                                 //比大的小
                        if (failure) failure(endIndex);
                    }
                }
            }
        }else{
            //5. 与mid对比
            NSInteger midIndex = (startIndex + endIndex) / 2;
            AIPointer *midPointer = ARR_INDEX(ids, midIndex);
            NSNumber *midValue = [[NSUserDefaults standardUserDefaults] objectForKey:midPointer.filePath];
            NSComparisonResult compareMid = [data compare:midValue];
            if (compareMid == NSOrderedAscending) { //比中心大(检查mid到endIndex)
                [self search:data fromIds:ids startIndex:midIndex endIndex:endIndex success:success failure:failure];
            }else if (compareMid == NSOrderedSame){ //相等
                if (success) success(midPointer);
            }else {                                 //比中心小(检查startIndex到mid)
                [self search:data fromIds:ids startIndex:startIndex endIndex:midIndex success:success failure:failure];
            }
        }
    }
}

@end


//MARK:===============================================================
//MARK:                     < AINetIndexModel >
//MARK:===============================================================
@interface AINetIndexModel ()
@end

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

