//
//  AINetCMV.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetCMV.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "AINode.h"

#define FILENAME_Node @"node"

@implementation AINetCMV

-(void) create:(NSArray*)imvAlgsArr order:(NSArray*)order{
    //1. 打包orderNodes;
    NSMutableArray *orders_kvp = [[NSMutableArray alloc] init];
    for (NSArray *algsArr_kvp in ARRTOOK(order)) {
        for (AIKVPointer *data_kvp in algsArr_kvp) {
            if (ISOK(data_kvp, AIKVPointer.class)) {
                AINode *node = [[AINode alloc] init];//node
                node.dataPointer = data_kvp;
                node.pointer = [SMGUtils createPointer:PATH_NET_NODE algsType:data_kvp.algsType dataSource:data_kvp.dataSource];
                PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:node.pointer.filePath];//save
                [pinCache setObject:node forKey:FILENAME_Node];
                [self createdNode:data_kvp nodePointer:node.pointer];//reference
                [orders_kvp addObject:node.pointer];
            }
        }
    }
    
    //2. 打包cmvNode;
    AINetCMVNode *cmvNode = [[AINetCMVNode alloc] init];//node
    NSString *cmvNodeAlgsType = @"cmv";
    for (AIKVPointer *itemIMV_kvp in ARRTOOK(imvAlgsArr)) {
        if (ISOK(itemIMV_kvp, AIKVPointer.class)) {
            if ([@"targetType" isEqualToString:itemIMV_kvp.dataSource]) {
                cmvNode.targetTypePointer = itemIMV_kvp;
                cmvNodeAlgsType = itemIMV_kvp.algsType;
            }else if([@"urgentValue" isEqualToString:itemIMV_kvp.dataSource]) {
                cmvNode.urgentValuePointer = itemIMV_kvp;
            }
        }
    }
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_NODE algsType:cmvNodeAlgsType dataSource:@"cmv"];
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvNode.pointer.filePath];//save
    [pinCache setObject:cmvNode forKey:FILENAME_Node];
    [self createdNode:cmvNode.targetTypePointer nodePointer:cmvNode.pointer];//reference
    [self createdNode:cmvNode.urgentValuePointer nodePointer:cmvNode.pointer];
    
    //3. 生成cmv模型,并存储
    AINetCMVModel *cmvModel = [[AINetCMVModel alloc] init];
    cmvModel.cmvPointer = cmvNode.pointer;
    [cmvModel.orders_kvp addObjectsFromArray:orders_kvp];
//    pinCache = [PINDiskCache alloc] initWithName:@"" rootPath:
    
    
    
    //4. 明日提示:将AINode分开类;此处使用为BaseNode;即:有dataPointer和rootPointer的Node;
    
    //5. 存到指定位置,并且返回给thinking,
}

-(void) createdNode:(AIKVPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMV_CreatedNode:nodePointer:)]) {
        [self.delegate aiNetCMV_CreatedNode:indexPointer nodePointer:nodePointer];
    }
}

@end


//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@implementation AINetCMVModel

-(NSMutableArray *)orders_kvp{
    if (_orders_kvp == nil) {
        _orders_kvp = [[NSMutableArray alloc] init];
    }
    return _orders_kvp;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.orders_kvp = [aDecoder decodeObjectForKey:@"orders_kvp"];
        self.cmvPointer = [aDecoder decodeObjectForKey:@"cmvPointer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.orders_kvp forKey:@"orders_kvp"];
    [aCoder encodeObject:self.cmvPointer forKey:@"cmvPointer"];
}

@end


//MARK:===============================================================
//MARK:                     < cmv节点 >
//MARK:===============================================================
@implementation AINetCMVNode

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.targetTypePointer = [aDecoder decodeObjectForKey:@"targetTypePointer"];
        self.urgentValuePointer = [aDecoder decodeObjectForKey:@"urgentValuePointer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.targetTypePointer forKey:@"targetTypePointer"];
    [aCoder encodeObject:self.urgentValuePointer forKey:@"urgentValuePointer"];
}

@end
