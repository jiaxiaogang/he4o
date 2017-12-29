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
-(AIModel*) insertInt:(int)data{
    NSInteger lastId = [SMGUtils getLastNetDataPointerId];
    [[AINetStore sharedInstance] setObject:nil folderName:@"Induction_Int" pointerId:lastId + 1];
    [SMGUtils setNetDataPointerId:lastId + 1];
    return nil;
}

-(AIModel*) insertFLoat:(float)data{
    return nil;
}

-(AIModel*) insertString:(NSString*)data{
    return nil;
}

-(AIModel*) insertChar:(char)data{
    return nil;
}

-(AIModel*) insertObj:(id)data{
    return nil;
}

-(AIModel*) insertArr:(NSArray*)data{
    return nil;
}

-(AIModel*) insertLogic:(id)data{
    //smg对logic的理解取决于:logic什么时候被触发,触发后,其实例执行了什么变化;
    return nil;
}

-(AIModel*) insertCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

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
-(AIModel*) searchInt:(int)data{
    
    NSInteger lastId = [SMGUtils getLastNetDataPointerId];
    [[AINetStore sharedInstance] setObject:nil folderName:@"Induction_Int" pointerId:lastId + 1];
    [SMGUtils setNetDataPointerId:lastId + 1];
    return nil;
}

-(AIModel*) searchFLoat:(float)data{
    return nil;
}

-(AIModel*) searchString:(NSString*)data{
    return nil;
}

-(AIModel*) searchChar:(char)data{
    return nil;
}

-(AIModel*) searchObj:(id)data{
    return nil;
}

-(AIModel*) searchArr:(NSArray*)data{
    return nil;
}

-(AIModel*) searchLogic:(id)data{
    //smg对logic的理解取决于:logic什么时候被触发,触发后,其实例执行了什么变化;
    return nil;
}

-(AIModel*) searchCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(AINetModel*) searchWithModel:(id)model{
    //[[AINetStore sharedInstance] objectForKvPointer:nil];
    return nil;
}

@end

