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
-(BOOL) setObject_NetNode:(AINode*)node{
    NSInteger lastId = [SMGUtils getLastNetNodePointerId];
    BOOL success = [self setObject:node folderName:NET_NODE pointerId:lastId + 1];
    if (success) {
        [SMGUtils setNetNodePointerId:lastId + 1];
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
 *  MARK:--------------------存节点和elementId的映射--------------------
 */
-(BOOL) setObject_NodePointerEId:(AIKVPointer*)nodePointer eId:(NSInteger)eId{
    return [self setObject:nodePointer folderName:MAP_NODEPOINTER_ELEMENTID pointerId:eId];///////////////估计AIObject.pointer是不需要的;因为path即pointer;并且指针即数据;没有指针;数据是无法操作的;
}

-(nonnull PINDiskCache*) getPinCache:(NSString*)filePath{
    for (NSString *key in self.pinCaches.allKeys) {
        if ([STRTOOK(key) isEqualToString:key]) {
            return [self.pinCaches objectForKey:STRTOOK(key)];
        }
    }
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:STRTOOK(filePath)];
    [self.pinCaches setObject:cache forKey:STRTOOK(filePath)];
    return cache;
}

@end
