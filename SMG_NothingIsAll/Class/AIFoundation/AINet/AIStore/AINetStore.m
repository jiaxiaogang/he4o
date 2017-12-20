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
-(BOOL) setObjectWithNetNode:(AINode*)node{
    NSInteger lastId = [SMGUtils getLastNetNodePointerId];
    BOOL success = [self setObject:node folderName:NET_NODE pointerId:lastId + 1];
    if (success) {
        [SMGUtils setNetNodePointerId:lastId + 1];
    }
    return success;
}

-(BOOL) setObjectWithNetData:(AIObject*)data{
    NSInteger lastId = [SMGUtils getLastNetDataPointerId];
    BOOL success = [self setObject:data folderName:NET_DATA pointerId:lastId + 1];
    if (success) {
        [SMGUtils setNetDataPointerId:lastId + 1];
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
-(/*AIObject**/id) objectForKvPointer:(AIKVPointer*)kvPointer{
    if (ISOK(kvPointer, AIKVPointer.class)) {
        PINDiskCache *cache = [self getPinCache:kvPointer.filePath];
        return [cache objectForKey:kvPointer.fileName];
    }
    return nil;
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
