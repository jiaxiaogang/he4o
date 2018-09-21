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
#import "ThinkingUtils.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"

@implementation AINetCMV

-(AINetCMVModel*) create:(NSArray*)imvAlgsArr order:(NSArray*)order{
    //1. 数据
    __block NSString *mvAlgsType = @"cmv";
    __block AIKVPointer *deltaPointer = nil;
    __block AIKVPointer *urgentToPointer = nil;
    __block NSInteger deltaValue = 0;
    __block NSInteger urgentToValue = 0;
    [ThinkingUtils parserAlgsMVArr:imvAlgsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        deltaPointer = delta_p;
        mvAlgsType = algsType;
        urgentToPointer = urgentTo_p;
        deltaValue = delta;
        urgentToValue = urgentTo;
    }];
    
    //2. 生成cmv模型
    AINetCMVModel *cmvModel = [[AINetCMVModel alloc] init];
    cmvModel.pointer = [SMGUtils createPointer:PATH_NET_CMVMODEL algsType:mvAlgsType dataSource:@""];
    
    //3. 打包cmvNode;
    AICMVNode *cmvNode = [[AICMVNode alloc] init];
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_CMV_NODE algsType:mvAlgsType dataSource:@""];
    cmvNode.cmvModel_p = cmvModel.pointer;
    cmvNode.delta_p = deltaPointer;
    cmvNode.urgentTo_p = urgentToPointer;
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:cmvNode.pointer.filePath];//save
    [pinCache setObject:cmvNode forKey:FILENAME_Node];
    [self createdNode:cmvNode.delta_p nodePointer:cmvNode.pointer];//reference
    [self createdNode:cmvNode.urgentTo_p nodePointer:cmvNode.pointer];
    [self createdCMVNode:cmvNode.pointer delta:deltaValue urgentTo:urgentToValue];
    
    //4. 打包foNode;
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];//node
    foNode.pointer = [SMGUtils createPointer:PATH_NET_FRONT_ORDER_NODE algsType:@"" dataSource:@""];
    foNode.cmvModel_kvp = cmvModel.pointer;
    for (AIPointer *data_kvp in ARRTOOK(order)) {
        if (ISOK(data_kvp, AIPointer.class)) {
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


/**
 *  MARK:--------------------用于,创建node后,将其插线到引用序列;--------------------
 */
-(void) createdNode:(AIPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMV_CreatedNode:nodePointer:)]) {
        [self.delegate aiNetCMV_CreatedNode:indexPointer nodePointer:nodePointer];
    }
}

-(void) createdCMVNode:(AIKVPointer*)cmvNode_p delta:(NSInteger)delta urgentTo:(NSInteger)urgentTo{
    MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;
    NSInteger difStrong = urgentTo;//暂时先相等;
    if (ISOK(cmvNode_p, AIKVPointer.class)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMV_CreatedCMVNode:mvAlgsType:direction:difStrong:)]) {
            [self.delegate aiNetCMV_CreatedCMVNode:cmvNode_p mvAlgsType:cmvNode_p.algsType direction:direction difStrong:difStrong];
        }
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
