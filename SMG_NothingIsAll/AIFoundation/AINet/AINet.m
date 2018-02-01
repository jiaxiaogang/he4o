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
#import "AILine.h"

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

//insertInt Float Char都由obj表示;
-(AINode*) insertObj:(id)data{
    return [[AINetStore sharedInstance] setObject_Define:data folderName:@"Induction_Int"];
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

-(AINode*) insertModel:(AIModel*)model energy:(NSInteger)energy{
    return [[AINetStore sharedInstance] setObject_Define:model];
}


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model{
    NSLog(@"更新存储AINode");
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

-(AINode*) searchLogic:(AIInputMindValueAlgsModel*)data{
    //smg对logic的理解取决于:logic什么时候被触发,触发后,其实例执行了什么变化;
    
    
    //向net存储一个logic;然后在此检索到...//xxx
    
    
    return nil;
}

-(AINode*) searchCan:(id)data{
    //smg对can的理解取决于:can什么时候被触发,及触发的目标是;
    return nil;
}

-(AINode*) searchWithModel:(id)model{
    return [[AINetStore sharedInstance] objectNodeForData:@('t')];
}

-(AINode*) searchAbstract_Induction:(NSString*)className{
    return [[AINetStore sharedInstance] objectNodeForDataType:className];
}

/**
 *  MARK:--------------------插网线--------------------
 *  每次产生神经网络的时候,要把网线插在网口上;
 */
-(void) connectLine:(AILine*)line{
    [self connectLine:line save:false];
}

-(void) connectLine:(AILine*)line save:(BOOL)save{
    if (LINEISOK(line) && POINTERISOK(line.pointer) && ![self containsLine:line]) {
        //[self.linePointers addObject:line.pointer];
    }
}

/**
 *  MARK:--------------------判断是否插了某网线--------------------
 */
-(BOOL) containsLine:(AILine*)line{
    if (LINEISOK(line)) {
//        for (AIPointer *pointer in self.linePointers) {
//            if (POINTERISOK(pointer)) {
//                if ([pointer isEqual:line.pointer]) {
//                    return true;
//                }
//            }
//        }
    }
    return false;
}

@end



