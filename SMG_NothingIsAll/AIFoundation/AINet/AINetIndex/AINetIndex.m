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

-(AIKVPointer*) setObject:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource {
    //1. 查找model
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
    
    if (model.pointerIds.count) {
        NSInteger startIndex = 0;
        NSInteger endIndex = model.pointerIds.count - 1;
        NSInteger checkIndex = (startIndex + endIndex) / 2;
        if (abs(startIndex - endIndex) == 1) {
            //与start和end分别对比
        }else if(startIndex == endIndex){
            //与start对比
        }else{
            //与check对比,
            
            //1. 相同时,返回checkIndex
            //2. >时,检查check到endIndex
            //3. <时,检查startIndex到check
        }
    }
    
    
    
    //根据dT&dS为key有序存到mDic;
    return nil;
}

-(AIKVPointer*) objectForModel:(NSObject*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    //根据dT&dS为key从mDic取出相应值的pointer
    return nil;
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

