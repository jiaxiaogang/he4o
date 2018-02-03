//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AINetStore.h"
#import "AINode.h"
#import "AIPointer.h"

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
//MARK:--------------------构建属性--------------------
-(void) insertProperty:(NSString*)propertyName{
    
}

//MARK:--------------------构建值--------------------
-(void) insertValue:(id)value{
    
}

//MARK:--------------------构建变化--------------------
-(void) insertChange:(id)change{
    
}

//MARK:--------------------构建父类--------------------
-(void) insertParent:(NSString*)parentName{
    
}

//MARK:--------------------构建子类--------------------
-(void) insertSubX:(id)subX{
    
}

//MARK:--------------------构建实例--------------------
-(void) insertInstance:(id)instance{
    
}

//MARK:--------------------构建接口--------------------
-(void) insertMethod:(NSString*)method{
    
}

-(AINode*) insertArr:(NSArray*)data{
    return nil;
}

-(AINode*) insertLogic:(id)data{
    //smg对logic的理解取决于:logic什么时候被触发,触发后,其实例执行了什么变化;
    return nil;
}

-(AINode*) insertCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer{
    
}

-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource energy:(NSInteger)energy{
    return [[AINetStore sharedInstance] setObjectModel:model dataSource:dataSource];
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model{
    NSLog(@"更新存储AINode");
}

-(void) updateNode:(AINode*)node abs:(AINode*)abs{
    [[AINetStore sharedInstance] updateNode:node abs:abs];
}

-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode{
    [[AINetStore sharedInstance] updateNode:node propertyNode:propertyNode];
}


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINode*) searchObj:(id)data{
    return nil;
}

-(AINode*) searchArr:(NSArray*)data{
    return nil;
}

-(AINode*) searchCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(AINode*) searchNodeForDataModel:(AIModel*)model{
    return nil;
}

-(AINode*) searchNodeForDataObj:(id)obj{
    return [[AINetStore sharedInstance] objectNodeForDataObj:obj];
}

-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString*)dataSource{
    return [[AINetStore sharedInstance] objectNodeForDataType:dataType dataSource:dataSource];
}

@end



