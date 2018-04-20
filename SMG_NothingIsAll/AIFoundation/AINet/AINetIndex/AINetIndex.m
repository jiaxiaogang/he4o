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

@property (strong,nonatomic) NSMutableDictionary *mDic;

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
//MARK:                     < AINetIndexModel >
//MARK:===============================================================
@interface AINetIndexModel ()

@property (strong,nonatomic) AIKVPointer *pointer;
@property (strong,nonatomic) NSString *dataType;
@property (strong,nonatomic) NSString *dataSource;

@end

@implementation AINetIndexModel : NSObject

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

