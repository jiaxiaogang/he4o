//
//  AINetData.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/3.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetData.h"
#import "AIPort.h"
#import "AIKVPointer.h"


/**
 *  MARK:--------------------索引数据分文件--------------------
 *  每个AIPointer只表示一个地址,为了性能优化,pointer指向的数据需要拆分存储;
 *  在索引的存储中,将值与 `第二序列` 分开;(第二序列是索引值的引用节点集合,按强度排序)
 */
#define FILENAME_Value @"value"
#define FILENAME_Ports @"ports"


@implementation AINetData

-(void) setObject:(NSNumber*)value algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    
}

-(NSNumber*) valueForPointerId:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    
    
    //AINetDataModel *model = [self objectForPointerId:pointerId algsType:algsType dataSource:dataSource];//不作整体模型,将value和ports拆分;
    
    
    AIKVPointer *pointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_REFERENCE algsType:algsType dataSource:dataSource];
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:pointer.filePath];
    
    
    if (model) {
        return model.value;
    }
    return nil;
}

-(void) updateObject:(AIPointer*)pointer{
    
}

@end


//MARK:===============================================================
//MARK:                     < itemDataModel (一条数据) >
//MARK:===============================================================
@implementation AINetDataModel : NSObject

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.ports = [aDecoder decodeObjectForKey:@"ports"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.ports forKey:@"ports"];
}

@end
