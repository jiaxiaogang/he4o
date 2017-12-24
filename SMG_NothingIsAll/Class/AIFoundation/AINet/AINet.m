//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AINetStore.h"
#import "AINetModel.h"

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
//MARK:                     < insert >
//MARK:===============================================================
-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer{
    
}

-(void) insertModel:(AIModel*)model {
    NSLog(@"存储Model");
    [[AINetStore sharedInstance] setObjectWithNetData:model];
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINetModel*)model{
    NSLog(@"更新存储AINetModel");
}


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINetModel*) searchWithModel:(id)model{
    //[[AINetStore sharedInstance] objectForKvPointer:nil];
    return nil;
}

@end

