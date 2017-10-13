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

#define kNET_FUNCMODEL @"kNET_FUNCMODEL"
#define kMAP_FUNCMODELPOINTER_ELEMENTID @"kMAP_FUNCMODELPOINTER_ELEMENTID"  //存FuncModel.Pointer和elementId的映射

#define NET_NODE @"NET_NODE"  //网络;元素为AINode;
#define MAP_NODEPOINTER_ELEMENTID @"MAP_NODEPOINTER_ELEMENTID"  //存节点指针和elementId的映射

@interface AINetStore ()

@property (strong,nonatomic) NSMutableDictionary *pinCaches;

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
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(BOOL) setObjectWithNetNode:(AINode*)node{
    NSInteger lastId = [SMGUtils getLastNetNodePointerId];
    BOOL success = [self setObject:node folderName:NET_NODE pointerId:lastId + 1];
    if (success) {
        [SMGUtils setNetNodePointerId:lastId + 1];
    }
    return success;
}

-(BOOL) setObjectWithFuncModel:(AIFuncModel*)funcModel{
    NSInteger lastId = [SMGUtils getLastNetFuncModelPointerId];
    BOOL success = [self setObject:funcModel folderName:kNET_FUNCMODEL pointerId:lastId + 1];
    if (success) {
        [SMGUtils setNetFuncModelPointerId:lastId + 1];
    }
    return success;
}

-(BOOL) setObject:(AIObject*)obj folderName:(NSString*)folderName pointerId:(NSInteger)pointerId{
    if (ISOK(obj, AIObject.class)) {
        //1. 生成指针
        AIKVPointer *kvPointer = [[AIKVPointer alloc] init];
        kvPointer.pointerId = pointerId;
        kvPointer.folderName = STRTOOK(folderName);
        
        //2. 存储
        obj.pointer = kvPointer;
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        [cache setObject:obj forKey:kvPointer.fileName];
        return true;
    }
    return false;
}


/**
 *  MARK:--------------------根据节点指针取节点--------------------
 */
-(AIObject*) objectForKvPointer:(AIKVPointer*)kvPointer{
    if (ISOK(kvPointer, AIKVPointer.class)) {
        NSLog(@"%@,%@",kvPointer.filePath,kvPointer.fileName);
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        return [cache objectForKey:kvPointer.fileName];
    }
    return nil;
}


/**
 *  MARK:--------------------存节点和elementId的映射--------------------
 */
-(BOOL) setMapWithNodePointer:(AIKVPointer*)nodePointer withEId:(NSInteger)eId{
    return [self setMapWithPointer:nodePointer folderName:MAP_NODEPOINTER_ELEMENTID withEId:eId];
}

-(BOOL) setMapWithFuncModelPointer:(AIKVPointer*)nodePointer withEId:(NSInteger)eId{
    return [self setMapWithPointer:nodePointer folderName:kMAP_FUNCMODELPOINTER_ELEMENTID withEId:eId];
}

-(BOOL) setMapWithPointer:(AIKVPointer*)pointer folderName:(NSString*)folderName withEId:(NSInteger)eId{
    if (ISOK(pointer, AIKVPointer.class)) {
        //1. 生成指针
        AIKVPointer *kvPointer = [[AIKVPointer alloc] init];
        kvPointer.pointerId = eId;
        kvPointer.folderName = STRTOOK(folderName);
        
        //2. 存储
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        [cache setObject:pointer forKey:kvPointer.fileName];
        return true;
    }
    return false;
}


/**
 *  MARK:--------------------是否已存过ElementId下的Node--------------------
 */
-(BOOL) containsNodeWithEId:(NSInteger)eId{
    return [self containsObjectWithEId:eId folderName:MAP_NODEPOINTER_ELEMENTID];
}

-(BOOL) containsFuncModelWithEId:(NSInteger)eId{
    return [self containsObjectWithEId:eId folderName:kMAP_FUNCMODELPOINTER_ELEMENTID];
}

-(BOOL) containsObjectWithEId:(NSInteger)eId folderName:(NSString*)folderName{
    AIKVPointer *nodePointer = [self getPointerFromMapWithFolderName:folderName withEId:eId];
    return ISOK(nodePointer, AIKVPointer.class);
}


/**
 *  MARK:--------------------get节点pointer根据eId--------------------
 */
-(AIKVPointer*) getNodePointerFromMapWithEId:(NSInteger)eId{
    return [self getPointerFromMapWithFolderName:MAP_NODEPOINTER_ELEMENTID withEId:eId];
}

-(AIKVPointer*) getFuncModelPointerFromMapWithEId:(NSInteger)eId{
    return [self getPointerFromMapWithFolderName:kMAP_FUNCMODELPOINTER_ELEMENTID withEId:eId];
}

-(AIKVPointer*) getPointerFromMapWithFolderName:(NSString*)folderName withEId:(NSInteger)eId{
    //1. 生成eId指针
    AIKVPointer *kvPointer = [[AIKVPointer alloc] init];
    kvPointer.pointerId = eId;
    kvPointer.folderName = STRTOOK(folderName);
    
    //2. 读硬件指针
    NSLog(@"%@,%@",kvPointer.filePath,kvPointer.fileName);
    
    
    PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
    AIKVPointer *nodePointer = [cache objectForKey:kvPointer.fileName];
    return nodePointer;
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

@end
