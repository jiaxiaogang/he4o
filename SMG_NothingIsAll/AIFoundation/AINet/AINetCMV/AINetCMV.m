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
    //1. 将orderPointer打包成node;
    NSMutableArray *orderPointers = [[NSMutableArray alloc] init];
    for (NSArray *itemOrder in ARRTOOK(order)) {
        for (AIKVPointer *dataPointer in itemOrder) {
            if (ISOK(dataPointer, AIKVPointer.class)) {
                AINode *node = [[AINode alloc] init];
                node.dataPointer = dataPointer;
                node.pointer = [SMGUtils createPointer:PATH_NET_NODE algsType:dataPointer.algsType dataSource:dataPointer.dataSource];
                PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:node.pointer.filePath];
                [pinCache setObject:node forKey:FILENAME_Node];
                [orderPointers addObject:node.pointer];
            }
        }
    }
    
    //2. 将imvAlgsArr打包成node;
    AINetCMVNode *cmvNode = [[AINetCMVNode alloc] init];
    NSString *cmvNodeAlgsType = @"cmv";
    for (AIKVPointer *mvPointer in ARRTOOK(imvAlgsArr)) {
        if (ISOK(mvPointer, AIKVPointer.class)) {
            if ([@"targetType" isEqualToString:mvPointer.dataSource]) {
                cmvNode.targetTypePointer = mvPointer;
                cmvNodeAlgsType = mvPointer.algsType;
            }else if([@"urgentValue" isEqualToString:mvPointer.dataSource]) {
                cmvNode.urgentValuePointer = mvPointer;
            }
        }
    }
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_NODE algsType:cmvNodeAlgsType dataSource:@"cmv"];
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvNode.pointer.filePath];
    [pinCache setObject:cmvNode forKey:FILENAME_Node];
    
    //3. 生成cmv模型,并存储
    AINetCMVModel *cmvModel = [[AINetCMVModel alloc] init];
    cmvModel.cmvPointer = cmvNode.pointer;
    [cmvModel.algsArrOrder addObjectsFromArray:orderPointers];
//    pinCache = [PINDiskCache alloc] initWithName:@"" rootPath:
    //存到指定位置,并且返回给thinking,
    //cmvModel引用了的每个orderNode;都要加入itemOrderNode的ports中;
    //按照现在的方式,每次cmvModel的构建,reference中的强度也要变化;
    
    //明天lv清这些数据的存储位置,并且lv清这些关联间,各指针的指向及强度问题;
    
    
    
    
    //4. order与mv都可以独立抽象;
    
    //5. 可以考虑将order作为mvNode的一个 "orderArr"存在;(或者说以timeWeight和strongWeight)存两个不同的排序方案
    
    
    
    
}

@end


//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@implementation AINetCMVModel

-(NSMutableArray *)algsArrOrder{
    if (_algsArrOrder == nil) {
        _algsArrOrder = [[NSMutableArray alloc] init];
    }
    return _algsArrOrder;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.algsArrOrder = [aDecoder decodeObjectForKey:@"algsArrOrder"];
        self.cmvPointer = [aDecoder decodeObjectForKey:@"cmvPointer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.algsArrOrder forKey:@"algsArrOrder"];
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
