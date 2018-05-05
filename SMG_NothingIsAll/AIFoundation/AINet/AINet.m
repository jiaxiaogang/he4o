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

@interface AINet ()

/**
 *  MARK:--------------------cacheLong--------------------
 *  存AINode(相当于Net的缓存区)(容量10000);
 *  改为内存缓存,存node和指向的data的缓存;关机时清除;
 */
@property (strong,nonatomic) NSMutableArray *cacheLong;
@property (strong, nonatomic) AINetIndex *netIndex;

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
-(NSMutableArray*) getAlgsArr:(NSObject*)algsModel {
    if (algsModel) {
        NSDictionary *modelDic = [NSObject getDic:algsModel containParent:true];
        NSMutableArray *algsArr = [[NSMutableArray alloc] init];
        NSString *algsType = NSStringFromClass(algsModel.class);
        
        //1. algsType & dataSource
        for (NSString *dataSource in modelDic.allKeys) {
            //1. 转换AIModel&dataType;//废弃!(参考n12p12)
            //2. 存储索引;
            NSObject *data = [modelDic objectForKey:dataSource];
            AIPointer *pointer = [self.netIndex getPointerWithData:data algsType:algsType dataSource:dataSource];
            if (pointer) {
                [algsArr addObject:pointer];
            }
        }
        return algsArr;
    }
    return nil;
}

-(NSArray*) getItemAlgsReference:(AIKVPointer*)pointer limit:(NSInteger)limit {
    return [self.netIndex getIndexReference:pointer limit:limit];
}

@end



