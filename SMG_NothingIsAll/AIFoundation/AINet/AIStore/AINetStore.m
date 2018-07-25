//
//  AINetStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/30.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINetStore.h"
#import "AIKVPointer.h"
#import "PINCache.h"
#import "AINode.h"
#import "AIModel.h"
#import "AIPort.h"

@interface AINetStore ()

@property (strong,nonatomic) NSMutableDictionary *pinCaches;
@property (strong,nonatomic) NSMutableDictionary *pinMemoryCaches;

@end

@implementation AINetStore

static AINetStore *_instance;
+(AINetStore*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINetStore alloc] init];
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
    self.pinCaches = [[NSMutableDictionary alloc] init];
    self.pinMemoryCaches = [[NSMutableDictionary alloc] init];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================



//MARK:===============================================================
//MARK:                     < setObject >
//MARK:===============================================================
-(AINode*) setObjectModel:(AIModel*)model dataSource:(NSString*)dataSource{
    if (ISOK(model, AIModel.class)) {
        NSString *dataType = nil;
        if ([model isKindOfClass:AIIdentifierModel.class]) {
            dataType = ((AIIdentifierModel*)model).identifier;
        }else{
            dataType = NSStringFromClass(model.class);
        }
        
        //1. 生成指针
        NSInteger pointerId = [SMGUtils createPointerId:dataType dataSource:dataSource];
        AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_ABSNODE algsType:@"" dataSource:dataSource];
        
        //2. 将AINode与AIModel各自存为pointerPath下的一个文件;(命名为node和data)
        AINode *modelNode = [[AINode alloc] init];
        modelNode.pointer = kvPointer;
        
        //3. 继承关系(所有类型默认继承自AINode)
        AINode *root = [self objectRootNode:dataType dataSource:dataSource];
        [modelNode.absPorts addObject:[AIPort newWithNode:root]];
        [root.conPorts addObject:[AIPort newWithNode:modelNode]];
        
        //4. 存
        [self setObjectNode:root];                      //root
        [self setObjectData:model pointer:kvPointer];   //model.Data
        [self setObjectNode:modelNode];                 //model.node
        
        return modelNode;
    }
    return nil;
}

-(void) setObjectNode:(AINode*)node{
    if (ISOK(node, AINode.class) && node.pointer) {
        PINDiskCache *cache = [self getPinCache:node.pointer.filePath];
        [cache setObject:node forKey:@"node"];
    }
}

-(void) setObjectData:(id)data pointer:(AIKVPointer*)pointer{
    if (data && ISOK(pointer, AIKVPointer.class)) {
        PINDiskCache *cache = [self getPinCache:pointer.filePath];
        [cache setObject:data forKey:@"data"];
    }
}


//MARK:===============================================================
//MARK:                     < objectForKey >
//MARK:===============================================================
-(id) objectDataForPointer:(AIKVPointer*)pointer{
    if (ISOK(pointer, AIKVPointer.class)) {
        PINDiskCache *cache = [self getPinCache:pointer.filePath];
        return [cache objectForKey:@"data"];
    }
    return nil;
}

-(AINode*) objectNodeForPointer:(AIKVPointer*)kvPointer{
    if (ISOK(kvPointer, AIKVPointer.class)) {
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        id node = [cache objectForKey:@"node"];
        if (ISOK(node, AINode.class)) {
            return node;
        }
    }
    return nil;
}

-(AINode*) objectNodeForDataModel:(AIModel*)model{
    return nil;
}

-(AINode*) objectNodeForDataObj:(id)obj {
    //1. 根据"int"抽象节点找子节点;
    //2. 判断子节点的值与obj相等;
    if (obj) {
        if([obj isKindOfClass:[NSNumber class]]){
            if (strcmp([obj objCType], @encode(char)) == 0){
                char c = [(NSNumber*)obj charValue];
                AINode *charNode = [self objectNodeForDataType:@"char" dataSource:nil];
                if (charNode) {
                    for (AIPort *port in charNode.conPorts) {
                        NSNumber *data = [self objectDataForPointer:port.target_p];//随后接入发音算法(参考n10p9)
                        if (ISOK(data, NSNumber.class)) {
                            if ([data charValue] == c) {
                                return [self objectNodeForPointer:port.target_p];
                            }
                        }
                    }
                }
            }else if (strcmp([obj objCType], @encode(int)) == 0){
                
            }
        }else {
            
        }
    }
    return false;
}

-(AINode*) objectNodeForDataType:(NSString*)dataType dataSource:(NSString*)dataSource {
    AINode *root = [self objectRootNode:dataType dataSource:dataSource];
    return root;
}

-(nonnull AINode*) objectRootNode:(NSString*)dataType dataSource:(NSString*)dataSource{
    //1. root.pointer;
    AIKVPointer *p = [AIKVPointer newWithPointerId:0 folderName:PATH_NET_ABSNODE algsType:@"" dataSource:dataSource];//将0定义为root;
    
    //2. 取rootNode
    AINode *root = [self objectNodeForPointer:p];
    
    //3. 无则存
    if (!ISOK(root, AINode.class)) {
        root = [[AINode alloc] init];
        root.pointer = p;
        [self setObjectNode:root];
    }
    return root;
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNode:(AINode*)node abs:(AINode*)absNode{
    if (ISOK(node, AINode.class)) {
        //1. 父类传入空则新建
        if (!ISOK(absNode, AINode.class)) {
            //1.1. get root
            NSString *dataSource = node.pointer.dataSource;
            AINode *root = [self objectRootNode:@"" dataSource:dataSource];
            //1.2. new absNode
            absNode = [[AINode alloc] init];
            absNode.pointer = [AIKVPointer newWithPointerId:[SMGUtils createPointerId:@"" dataSource:dataSource] folderName:PATH_NET_ABSNODE algsType:@"" dataSource:dataSource];
            [absNode.absPorts addObject:[AIPort newWithNode:root]];
            //1.3. save root
            [root.conPorts addObject:[AIPort newWithNode:absNode]];
            [self setObjectNode:root];
        }
        
        //2. 指定继承关系
        [node.absPorts addObject:[AIPort newWithNode:absNode]];
        [absNode.conPorts addObject:[AIPort newWithNode:node]];
        
        //3. 从子类向父类融信息(属性值范围)
        //...
        
        //4.存
        [self setObjectNode:node];
        [self setObjectNode:absNode];
    }
}

-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode{
    //代码层不进行信息迁移;
    if (ISOK(node, AINode.class) && ISOK(propertyNode, AINode.class)) {
        //1. 指定属性关系
        [node.propertyPorts addObject:[AIPort newWithNode:propertyNode]];
        [propertyNode.bePropertyPorts addObject:[AIPort newWithNode:node]];
        
        //2. 从node的父类向融信息(属性及属性值范围)(模糊关系)(参考n10p22)
        //...
        
        //3.存
        [self setObjectNode:node];
        [self setObjectNode:propertyNode];
    }
}

-(void) updateNode:(AINode *)node changeNode:(AINode *)changeNode{
    if (ISOK(node, AINode.class) && ISOK(changeNode, AINode.class)) {
        //1. 指定关系
        [node.changePorts addObject:[AIPort newWithNode:changeNode]];
        [changeNode.beChangePorts addObject:[AIPort newWithNode:node]];
        
        //2.存
        [self setObjectNode:node];
        [self setObjectNode:changeNode];
    }
}

-(void) updateNode:(AINode *)node logicNode:(AINode *)logicNode{
    if (ISOK(node, AINode.class) && ISOK(logicNode, AINode.class)) {
        //1. 指定关系
        [node.logicPorts addObject:[AIPort newWithNode:logicNode]];
        [logicNode.beLogicPorts addObject:[AIPort newWithNode:node]];
        
        //2.存
        [self setObjectNode:node];
        [self setObjectNode:logicNode];
    }
}

/**
 *  MARK:--------------------PINCache缓存--------------------
 */
-(nonnull PINDiskCache*) getPinCache:(NSString*)filePath{
    for (NSString *key in self.pinCaches.allKeys) {
        if ([STRTOOK(key) isEqualToString:filePath]) {
            return [self.pinCaches objectForKey:STRTOOK(key)];
        }
    }
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:STRTOOK(filePath)];
    [self.pinCaches setObject:cache forKey:STRTOOK(filePath)];
    return cache;
}


//MARK:===============================================================
//MARK:                     < AILine >
//MARK:===============================================================
//+(AILine*) ailine_CreateLine:(NSArray*)aiObjs type:(AILineType)type{
//    if (ARRISOK(aiObjs)) {
//        //1. 创建网线并存
//        AILine *line = AIMakeLine(type, aiObjs);
//        [AILineStore insert:line];
//        //2. 插网线
//        if (ARRISOK(aiObjs)) {
//            for (AIObject *obj in aiObjs) {
//                if (ISOK(obj, AIObject.class)) {
//                    [obj connectLine:line save:true];
//                }
//            }
//        }
//        return line;
//    }else{
//        NSLog(@"_______SMGUtils.CreateLine.ERROR (pointersIsNil!)");
//        return nil;
//    }
//}

@end




@implementation AINetStore (Memory)

-(nonnull PINMemoryCache*) getPinMemoryCache:(NSString*)filePath{
    for (NSString *key in self.pinMemoryCaches.allKeys) {
        if ([STRTOOK(key) isEqualToString:filePath]) {
            return [self.pinMemoryCaches objectForKey:STRTOOK(key)];
        }
    }
    PINMemoryCache *cache = [PINMemoryCache sharedCache];//initWithName:@"" rootPath:STRTOOK(filePath)];
    [self.pinMemoryCaches setObject:cache forKey:STRTOOK(filePath)];
    return cache;
}

@end
