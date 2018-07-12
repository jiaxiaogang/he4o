//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AINetStore.h"
#import "AINode.h"
#import "AIPointer.h"
#import "NSObject+Extension.h"
#import "AINetIndex.h"
#import "AINetCMV.h"
#import "AIPort.h"
#import "AINetAbs.h"
#import "AINetAbsIndex.h"
#import "AINetDirectionReference.h"

@interface AINet () <AINetCMVDelegate>

/**
 *  MARK:--------------------cacheLong--------------------
 *  存AINode(相当于Net的缓存区)(容量10000);
 *  改为内存缓存,存node和指向的data的缓存;关机时清除;
 */
@property (strong,nonatomic) NSMutableArray *cacheLong;
@property (strong, nonatomic) AINetIndex *netIndex; //索引区(皮层/海马)
@property (strong, nonatomic) AINetCMV *netCMV;     //网络树根(杏仁核)
@property (strong, nonatomic) AINetAbs *netAbs;     //抽具象序列
@property (strong, nonatomic) AINetAbsIndex *netAbsIndex;//宏信息索引区(海马)
@property (strong, nonatomic) AINetDirectionReference *netDirectionReference;

@end

@implementation AINet

static AINet *_instance;
+(AINet*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINet alloc] init];
    }
    return _instance;
}


-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.cacheLong = [[NSMutableArray alloc] init];
    self.netIndex = [[AINetIndex alloc] init];
    self.netCMV = [[AINetCMV alloc] init];
    self.netCMV.delegate = self;
    self.netAbs = [[AINetAbs alloc] init];
    self.netAbsIndex = [[AINetAbsIndex alloc] init];
    self.netDirectionReference = [[AINetDirectionReference alloc] init];
}


//MARK:===============================================================
//MARK:                     < insert >
//MARK:===============================================================
//MARK:--------------------构建属性--------------------
-(void) insertProperty:(NSString*)propertyName{
    
}

//MARK:--------------------构建值--------------------
-(void) insertValue:(id)value{
    
}

//MARK:--------------------构建变化--------------------
-(void) insertChange:(id)change{
    
}

//MARK:--------------------构建父类--------------------
-(void) insertParent:(NSString*)parentName{
    
}

//MARK:--------------------构建子类--------------------
-(void) insertSubX:(id)subX{
    
}

//MARK:--------------------构建实例--------------------
-(void) insertInstance:(id)instance{
    
}

//MARK:--------------------构建接口--------------------
-(void) insertMethod:(NSString*)method{
    
}

-(AINode*) insertArr:(NSArray*)data{
    return nil;
}

-(AINode*) insertLogic:(id)data{
    //smg对logic的理解取决于:logic什么时候被触发,触发后,其实例执行了什么变化;
    return nil;
}

-(AINode*) insertCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer{
    
}

-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource energy:(NSInteger)energy{
    AINode *node = [[AINetStore sharedInstance] setObjectModel:model dataSource:dataSource];
    [self setObject_Caches:node];
    return node;
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model{
    NSLog(@"更新存储AINode");
}

-(void) updateNode:(AINode*)node abs:(AINode*)abs{
    [[AINetStore sharedInstance] updateNode:node abs:abs];
}

-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode{
    [[AINetStore sharedInstance] updateNode:node propertyNode:propertyNode];
}

-(void) updateNode:(AINode *)node changeNode:(AINode *)changeNode{
    [[AINetStore sharedInstance] updateNode:node changeNode:changeNode];
}

-(void) updateNode:(AINode *)node logicNode:(AINode *)logicNode{
    [[AINetStore sharedInstance] updateNode:node logicNode:logicNode];
}

//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINode*) searchObj:(id)data{
    return nil;
}

-(AINode*) searchArr:(NSArray*)data{
    return nil;
}

-(AINode*) searchCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(AINode*) searchNodeForDataModel:(AIModel*)model{
    return nil;
}

-(AINode*) searchNodeForDataObj:(id)obj{
    //1. 从cacheLong搜索
    for (AINode *node in self.cacheLong) {
        
    }
    
    //2. 从store搜索
    AINode *node = [[AINetStore sharedInstance] objectNodeForDataObj:obj];
    [self setObject_Caches:node];
    return node;
}

-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString*)dataSource{
    //1. 从cacheLong搜索
    for (AINode *node in self.cacheLong) {
        
    }
    
    //2. 从store搜索
    AINode *node = [[AINetStore sharedInstance] objectNodeForDataType:dataType dataSource:dataSource];
    [self setObject_Caches:node];
    return node;
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setObject_Caches:(AINode*)node {
    //cacheLong
    if (ISOK(node, AINode.class)) {
        [self.cacheLong addObject:node];
        if (self.cacheLong.count > 10000) {
            [self.cacheLong subarrayWithRange:NSMakeRange(self.cacheLong.count - 10000, 10000)];
        }
    }
}

//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*)   getAlgsArr:(NSObject*)algsModel {
    if (algsModel) {
        NSDictionary *modelDic = [NSObject getDic:algsModel containParent:true];
        NSMutableArray *algsArr = [[NSMutableArray alloc] init];
        NSString *algsType = NSStringFromClass(algsModel.class);
        
        //1. algsType & dataSource
        for (NSString *dataSource in modelDic.allKeys) {
            //1. 转换AIModel&dataType;//废弃!(参考n12p12)
            //2. 存储索引;
            NSObject *data = [modelDic objectForKey:dataSource];
            AIPointer *pointer = [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource];
            if (pointer) {
                [algsArr addObject:pointer];
            }
        } 
        return algsArr;
    }
    return nil;
}

-(void) setItemAlgsReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.netIndex setIndexReference:indexPointer target_p:target_p difValue:difValue];
}

-(NSArray*) getItemAlgsReference:(AIKVPointer*)pointer limit:(NSInteger)limit {
    return [self.netIndex getIndexReference:pointer limit:limit];
}


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AINetCMVModel*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order{
    return [self.netCMV create:imvAlgsArr order:order];
}


/**
 *  MARK:--------------------AINetCMVDelegate--------------------
 */
-(void)aiNetCMV_CreatedNode:(AIKVPointer *)indexPointer nodePointer:(AIKVPointer *)nodePointer{
    [self setItemAlgsReference:indexPointer target_p:nodePointer difValue:1];
}


//MARK:===============================================================
//MARK:                     < abs >
//MARK:===============================================================
-(AINetAbsNode*) createAbs:(NSArray*)foNodes refs_p:(NSArray*)refs_p{
    return [self.netAbs create:foNodes refs_p:refs_p];
}


//MARK:===============================================================
//MARK:                     < absIndex >
//MARK:===============================================================
-(AIKVPointer*) getNetAbsIndex_AbsPointer:(NSArray*)refs_p{
    return [self.netAbsIndex getAbsValuePointer:refs_p];
}
-(void) setAbsIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.netAbsIndex setIndexReference:indexPointer target_p:target_p difValue:difValue];
}
-(AIKVPointer*) getItemAbsNodePointer:(AIKVPointer*)absValue_p{
    return [self.netAbsIndex getAbsNodePointer:absValue_p];
}


//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(int)limit{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:limit];
}

-(void) setNetNodePointerToDirectionReference:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(int)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:cmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}

@end



