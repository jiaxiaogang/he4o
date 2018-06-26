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

@implementation AINetCMV

-(AINetCMVModel*) create:(NSArray*)imvAlgsArr order:(NSArray*)order{
    //1. 数据
    NSString *cmvNodeAlgsType = @"cmv";
    AIKVPointer *targetTypePointer = nil;
    AIKVPointer *urgentValuePointer = nil;
    for (AIKVPointer *itemIMV_kvp in ARRTOOK(imvAlgsArr)) {
        if (ISOK(itemIMV_kvp, AIKVPointer.class)) {
            if ([@"targetType" isEqualToString:itemIMV_kvp.dataSource]) {
                targetTypePointer = itemIMV_kvp;
                cmvNodeAlgsType = itemIMV_kvp.algsType;
            }else if([@"urgentValue" isEqualToString:itemIMV_kvp.dataSource]) {
                urgentValuePointer = itemIMV_kvp;
            }
        }
    }
    
    //2. 生成cmv模型
    AINetCMVModel *cmvModel = [[AINetCMVModel alloc] init];
    cmvModel.pointer = [SMGUtils createPointer:PATH_NET_CMVMODEL algsType:cmvNodeAlgsType dataSource:@""];
    
    //3. 打包cmvNode;
    AICMVNode *cmvNode = [[AICMVNode alloc] init];
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_CMV_NODE algsType:cmvNodeAlgsType dataSource:@""];
    cmvNode.cmvModel_kvp = cmvModel.pointer;
    cmvNode.targetTypePointer = targetTypePointer;
    cmvNode.urgentValuePointer = urgentValuePointer;
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvNode.pointer.filePath];//save
    [pinCache setObject:cmvNode forKey:FILENAME_Node];
    [self createdNode:cmvNode.targetTypePointer nodePointer:cmvNode.pointer];//reference
    [self createdNode:cmvNode.urgentValuePointer nodePointer:cmvNode.pointer];
    
    //4. 打包foNode;
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];//node
    foNode.pointer = [SMGUtils createPointer:PATH_NET_FRONT_ORDER_NODE algsType:@"" dataSource:@""];
    foNode.cmvModel_kvp = cmvModel.pointer;
    for (AIKVPointer *data_kvp in ARRTOOK(order)) {
        if (ISOK(data_kvp, AIKVPointer.class)) {
            [foNode.orders_kvp addObject:data_kvp];
            [self createdNode:data_kvp nodePointer:foNode.pointer];//reference
        }
    }
    
    pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:foNode.pointer.filePath];//save
    [pinCache setObject:foNode forKey:FILENAME_Node];
    
    //5. 存储cmv模型
    cmvModel.foNode_p = foNode.pointer;
    cmvModel.cmvNode_p = cmvNode.pointer;
    pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvModel.pointer.filePath];//save
    [pinCache setObject:cmvModel forKey:FILENAME_CMVModel];
    
    //6. 返回给thinking
    return cmvModel;
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

-(void) create{
    //1. 构建抽象node;
    //2. 抽象node由微信息组成;
    //3. 参考n12p19
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.foNode_p = [aDecoder decodeObjectForKey:@"foNode_p"];
        self.cmvNode_p = [aDecoder decodeObjectForKey:@"cmvNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.foNode_p forKey:@"foNode_p"];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
}

@end


//MARK:===============================================================
//MARK:                     < cmv节点 >
//MARK:===============================================================
@implementation AICMVNode

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.targetTypePointer = [aDecoder decodeObjectForKey:@"targetTypePointer"];
        self.urgentValuePointer = [aDecoder decodeObjectForKey:@"urgentValuePointer"];
        self.cmvModel_kvp = [aDecoder decodeObjectForKey:@"cmvModel_kvp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.targetTypePointer forKey:@"targetTypePointer"];
    [aCoder encodeObject:self.urgentValuePointer forKey:@"urgentValuePointer"];
    [aCoder encodeObject:self.cmvModel_kvp forKey:@"cmvModel_kvp"];
}

@end


//MARK:===============================================================
//MARK:                     < 前因序列_节点(多级神经元) >
//MARK:===============================================================
@implementation AIFrontOrderNode


-(NSMutableArray *)orders_kvp{
    if (_orders_kvp == nil) {
        _orders_kvp = [[NSMutableArray alloc] init];
    }
    return _orders_kvp;
}

-(NSMutableArray *)absPorts{
    if (_absPorts == nil) {
        _absPorts = [NSMutableArray new];
    }
    return _absPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.orders_kvp = [aDecoder decodeObjectForKey:@"orders_kvp"];
        self.cmvModel_kvp = [aDecoder decodeObjectForKey:@"cmvModel_kvp"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.orders_kvp forKey:@"orders_kvp"];
    [aCoder encodeObject:self.cmvModel_kvp forKey:@"cmvModel_kvp"];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
}

@end
