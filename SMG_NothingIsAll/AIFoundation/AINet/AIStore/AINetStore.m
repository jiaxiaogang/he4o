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
        [SMGUtils setNetNodePointerId:lastId + 1];
    }
    return lastId + 1;
}

-(AINode*) setObject:(AIModel*)data{
    return [self setObject:data folderName:NET_DATA pointerId:[self createPointerId]];
}

-(AINode*) setObject:(AIModel*)data folderName:(NSString*)folderName pointerId:(NSInteger)pointerId{
    if (ISOK(data, AIModel.class)) {
        //1. 生成指针
        AIKVPointer *kvPointer = [[AIKVPointer alloc] init];
        kvPointer.pointerId = pointerId;
        kvPointer.folderName = STRTOOK(folderName);
        
        //2. 将AINode与AIModel各自存为pointerPath下的一个文件;(命名为node和data)
        AINode *modelNode = [[AINode alloc] init];
        modelNode.pointer = kvPointer;
        
        //3. 继承关系(所有AIModel存储初期都继承自AINode)
        AINode *superNode = [self nodeForClass:AINode.class];
        [modelNode.isAPorts addObject:superNode.pointer];
        [superNode.subPorts addObject:modelNode.pointer];
        
        //4. 存superNode
        PINDiskCache *cache = [self getPinCache:superNode.pointer.filePath];
        [cache setObject:superNode forKey:@"node"];
        
        //5. 存储modelNode
        cache = [self getPinCache:kvPointer.filePath];
        [cache setObject:data forKey:@"data"];
        [cache setObject:modelNode forKey:@"node"];
        
        return modelNode;
    }
    return nil;
}


/**
 *  MARK:--------------------根据节点指针取节点--------------------
 */
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

//从根部开始找Class节点;
-(AINode*) nodeForClass:(Class)c{
    
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
