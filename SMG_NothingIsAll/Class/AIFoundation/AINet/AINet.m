//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AINetStore.h"

@interface AINet ()

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
    
}

//MARK:===============================================================
//MARK:                     < 事务对接区(AIObject内感) >
//MARK:===============================================================
-(void) commitString:(NSString*)str{
    if (STRISOK(str)) {
        
    }
}

-(void) commitInput:(id)input{
    
}

-(void) commitProperty:(id)data rootPointer:(AIPointer*)rootPointer{
    
}

-(void) commitModel:(AIModel*)model{
    NSLog(@"");
}

@end
