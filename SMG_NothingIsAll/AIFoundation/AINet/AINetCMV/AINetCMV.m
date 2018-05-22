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
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_CMVNODE algsType:cmvNodeAlgsType dataSource:@""];
    cmvNode.cmvModel_kvp = cmvModel.pointer;
    cmvNode.targetTypePointer = targetTypePointer;
    cmvNode.urgentValuePointer = urgentValuePointer;
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvNode.pointer.filePath];//save
    [pinCache setObject:cmvNode forKey:FILENAME_Node];
    [self createdNode:cmvNode.targetTypePointer nodePointer:cmvNode.pointer];//reference
    [self createdNode:cmvNode.urgentValuePointer nodePointer:cmvNode.pointer];
    
    //4. 打包orderNodes;
    for (NSArray *algsArr_kvp in ARRTOOK(order)) {
        for (AIKVPointer *data_kvp in algsArr_kvp) {
            if (ISOK(data_kvp, AIKVPointer.class)) {
                AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];//node
                foNode.data_kvp = data_kvp;
                foNode.pointer = [SMGUtils createPointer:PATH_NET_FONODE algsType:data_kvp.algsType dataSource:data_kvp.dataSource];
                foNode.cmvModel_kvp = cmvModel.pointer;
                PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:foNode.pointer.filePath];//save
                [pinCache setObject:foNode forKey:FILENAME_Node];
                [self createdNode:data_kvp nodePointer:foNode.pointer];//reference
                [cmvModel.orders_kvp addObject:foNode.pointer];
            }
        }
    }
    
    //5. 存储cmv模型
    cmvModel.cmvPointer = cmvNode.pointer;
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

-(NSMutableArray *)orders_kvp{
    if (_orders_kvp == nil) {
        _orders_kvp = [[NSMutableArray alloc] init];
    }
    return _orders_kvp;
}

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
        self.orders_kvp = [aDecoder decodeObjectForKey:@"orders_kvp"];
        self.cmvPointer = [aDecoder decodeObjectForKey:@"cmvPointer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.orders_kvp forKey:@"orders_kvp"];
    [aCoder encodeObject:self.cmvPointer forKey:@"cmvPointer"];
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
//MARK:                     < 前因序列_节点 >
//MARK:===============================================================
@implementation AIFrontOrderNode

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.data_kvp = [aDecoder decodeObjectForKey:@"data_kvp"];
        self.cmvModel_kvp = [aDecoder decodeObjectForKey:@"cmvModel_kvp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.data_kvp forKey:@"data_kvp"];
    [aCoder encodeObject:self.cmvModel_kvp forKey:@"cmvModel_kvp"];
}

@end
