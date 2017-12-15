//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "CodeLayerHeader.h"
#import "AINetStore.h"

@interface AINet ()

@property (strong,nonatomic) NSMutableArray *stringNodes;

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
    self.stringNodes = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < String反射区 >
//MARK:===============================================================
-(void) commitString:(NSString*)str{
    
    //2, 调用反射算法处理并返回值给临时神经网络缓存区;_______________________________//xxxxx
    
    if (STRISOK(str)) {
        //1. 必调字符串算法;
        //[[[AINetEditor alloc] init] tmpRun];
        
        for (AIKVPointer *nodePointer in self.stringNodes) {
            AIMultiNode *multiNode = [[AINetStore sharedInstance] objectForKvPointer:nodePointer];
            if (ISOK(multiNode, AIMultiNode.class)) {
                [multiNode run:@[str]];
            }
        }
    }
}


//MARK:===============================================================
//MARK:                     < AIObject反射区(内感) >
//MARK:===============================================================
-(void) commitModel:(AIModel*)model{
    NSLog(@"");
}


//MARK:===============================================================
//MARK:                     < 建设input对接net功能区 >
//MARK:===============================================================
-(void) addStringNode:(AIKVPointer*)kvPointer{
    if (ISOK(kvPointer, AIKVPointer.class)) {
        [self.stringNodes addObject:kvPointer];
    }
}



@end
