//
//  AINetDataSort.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/4/17.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetDataSort.h"
#import "AIKVPointer.h"
#import "AIModel.h"

@interface AINetDataSort ()

@property (strong,nonatomic) NSMutableDictionary *mDic;

@end

@implementation AINetDataSort

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.mDic = [[NSMutableDictionary alloc] init];
    //加载本地xxx
}

-(void) setObject:(AIModel*)aiModel dataSource:(NSString*)dataSource kvPointer:(AIKVPointer*)kvPointer{
    //根据dT&dS为key有序存到mDic;
}

-(AIKVPointer*) objectForModel:(AIModel*)model dataSource:(NSString*)dataSource{
    //根据dT&dS为key从mDic取出相应值的pointer
    return nil;
}

@end


//MARK:===============================================================
//MARK:                     < 内存DataSortModel >
//MARK:===============================================================
@interface AINetDataSortModel ()

@property (strong,nonatomic) AIKVPointer *pointer;
@property (strong,nonatomic) NSString *dataType;
@property (strong,nonatomic) NSString *dataSource;

@end

@implementation AINetDataSortModel : NSObject

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.dataType = [aDecoder decodeObjectForKey:@"dataType"];
        self.dataSource = [aDecoder decodeObjectForKey:@"dataSource"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.dataType forKey:@"dataType"];
    [aCoder encodeObject:self.dataSource forKey:@"dataSource"];
}

@end

