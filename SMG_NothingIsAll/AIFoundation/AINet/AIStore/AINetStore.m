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

#define NET_DATA @"NET_DATA"  //神经网络的数据;元素为AIObject;

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
-(NSInteger) createPointerId{
    return [self createPointerId:true];
}

-(NSInteger) createPointerId:(BOOL)updateLastId{
    NSInteger lastId = [SMGUtils getLastNetNodePointerId];
    if (updateLastId) {
        [SMGUtils setNetNodePointerId:1];
    }
    return lastId + 1;
}


//MARK:===============================================================
//MARK:                     < setObject >
//MARK:===============================================================
-(AINode*) setObject:(AIModel*)data{
    return [self setObject:data folderName:NET_DATA];
}

-(AINode*) setObject:(AIModel*)data folderName:(NSString*)folderName{
    if (ISOK(data, AIModel.class)) {
        //1. 生成指针
        AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:[self createPointerId] folderName:folderName];
        
        //2. 将AINode与AIModel各自存为pointerPath下的一个文件;(命名为node和data)
        AINode *modelNode = [[AINode alloc] init];
        modelNode.pointer = kvPointer;
        modelNode.dataType = NSStringFromClass(data.class);
        
        //3. 继承关系(所有类型默认继承自AINode)
        AINode *root = [self objectRootNode];
        [modelNode.absPorts addObject:root.pointer];
        [root.conPorts addObject:modelNode.pointer];
        
        //4. 存
        [self setObjectNode:root];//root
        [self setObjectData:data pointer:kvPointer];//model.Data
        [self setObjectNode:modelNode];//model.node
        
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
-(/*AIObject**/id) objectForKvPointer:(AIKVPointer*)kvPointer{
    if (ISOK(kvPointer, AIKVPointer.class)) {
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        return [cache objectForKey:@"data"];
    }
    return nil;
}

-(BOOL) objectFor:(id)obj folderName:(NSString*)folderName {
    //1. 根据"int"抽象节点找子节点;
    //2. 判断子节点的值与obj相等;
    return false;
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

//从根部开始找Class节点;
-(AINode*) objectNodeForClass:(Class)c{
    AINode *root = [self objectRootNode];
    for (AIKVPointer *p in root.conPorts) {
        NSLog(@"");
    }
    
    return nil;
}

-(nonnull AINode*) objectRootNode{
    //1. root.pointer;
    AIKVPointer *p = [[AIKVPointer alloc] init];
    p.pointerId = 0;//将0定义为"我";
    p.folderName = NET_DATA;
    
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
            AINode *root = [self objectRootNode];
            //1.2. new absNode
            absNode = [[AINode alloc] init];
            absNode.pointer = [AIKVPointer newWithPointerId:[self createPointerId] folderName:node.pointer.folderName];
            [absNode.absPorts addObject:root.pointer];
            //1.3. save root
            [root.conPorts addObject:absNode];
            [self setObjectNode:root];
        }
        
        //2. 指定继承关系
        [node.absPorts addObject:absNode.pointer];
        [absNode.conPorts addObject:node.pointer];
        
        //3. 从子类向父类融信息(属性值范围)
        absNode.dataType = STRTOOK(node.dataType);
        //...
        
        //4.存
        [self setObjectNode:node];
        [self setObjectNode:absNode];
    }
}

//*. 发现规律后,
//1. 新建节点;
//2. 新建属性;(需propertyNode)
//3. 更新节点;(中间继承层)
//4. 更新属性;(同3);
-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode{
    //代码层不进行信息迁移;
    
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
