//
//  AIThinkingControl.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/11/12.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIThinkingControl.h"
#import "AINet.h"
#import "ImvAlgsModelBase.h"
#import "AIActionControl.h"
#import "AINode.h"
#import "AIModel.h"
#import "NSObject+Extension.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "ImvAlgsModelBase.h"
#import "AINetCMV.h"

@interface AIThinkingControl()

@property (strong,nonatomic) NSMutableArray *cacheShort;//存AIModel(从Algs传入,待Thinking取用分析)(容量8);

@end

@implementation AIThinkingControl

static AIThinkingControl *_instance;
+(AIThinkingControl*) shareInstance{
    if (_instance == nil) {
        _instance = [[AIThinkingControl alloc] init];
    }
    return _instance;
}

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
        [self initRun];
    }
    return self;
}

-(void) initData{
    self.cacheShort = [[NSMutableArray alloc] init];
}

-(void) initRun{
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) commitInput:(NSObject*)algsModel{
    //[self dataIn_V1:algsModel];
    [self dataIn:algsModel];
}

-(void) dataIn_V1:(NSObject*)algsModel{
    //1. 数据
    NSDictionary *algsDic = [NSObject getDic:algsModel containParent:true];
    NSMutableDictionary *nodeDic = [[NSMutableDictionary alloc] init];
    AIActionControl *ac = [[AIActionControl alloc] init];
    
    //2. 构建algsModel并收集node;
    if (algsDic) {
        //3. 构建key节点
        NSString *dataType = NSStringFromClass(algsModel.class);
        AINode *identNode = [ac createIdentNode:dataType];
        if (identNode) [nodeDic setObject:identNode forKey:@"identNode"];
        
        //4. 取energy
        int energy = 0;
        for (NSString *dataSource in algsDic.allKeys) {
            if ([@"urgentValue" isEqualToString:dataSource]) {//imv检查
                NSInteger urgentValue = [NUMTOOK([algsDic objectForKey:@"urgentValue"]) integerValue];
                energy = 10;
            }else if([@"targetType" isEqualToString:dataSource]) {
                AITargetType targetType = [NUMTOOK([algsDic objectForKey:@"targetType"]) intValue];
                energy = 20;
            }
        }
        
        //5. 构建key属性
        NSMutableArray *pptNodes = [[NSMutableArray alloc] init];
        for (NSString *dataSource in algsDic.allKeys) {
            id propertyObj = [algsDic objectForKey:dataSource];
            
            //6. value为数组时,转换为node数组;
            if ([propertyObj isKindOfClass:NSArray.class]) {
                NSArray *items = [ac createPropertyNodes:propertyObj dataSource:dataSource identNode:identNode];
                propertyObj = items;
            }
            
            //7. 构建属性node;
            AINode *pptNode = [ac createPropertyNode:propertyObj dataSource:dataSource identNode:identNode];
            if (pptNode) [pptNodes addObject:pptNode];
        }
        [nodeDic setObject:pptNodes forKey:@"pptNodes"];
        
        //8. 构建change和logic链 (对各种change,用潜意识流logic串起来)
        
        
        //因algsDic定义只是存储结构,并非归纳结构,所以应类比Law,并thinkingRIN后,再产生归纳结构网络;//xxx
        //shortCaches和longCaches中存储的也是RIN后的数据,而非algsDic;//xxx
        
        //1. 对比value并找到规律,生成第一个RIN;参考n11p9(生成第一个RIN-代码例)
        //2. 完全以类比的结果为依据创建结构化网络;
        [ac searchNodeForDataObj:nil];
        
        for (NSDictionary *pptNode in pptNodes) {
            NSLog(@"");
            //逐个类比input中的信息单元(如char)等;找出law;
        }
    }
    
    //3. 存cacheShort
    [self setObject_Caches:nodeDic];
    
    //4. 提交思维循环
    [self thinkLoop:nodeDic];
}


/**
 *  MARK:--------------------思维循环--------------------
 *  1. 优化级;(经验->多事务分析->感觉猜测->cacheShort瞎关联)
 *  2. 符合度;(99%->1%)
 *  3. 类比原则:先用dataType和dataSource取,后存,再类比后作update结构化;
 */
-(void) thinkLoop:(NSDictionary*)nodeDic {
    if (nodeDic) {
        //1. 取mv
        
        //2. 联想mv
        
        //3. 根据cmv查找结果进行类比解决问题 (对导致cmv变化的change,进行类比缩小范围)
        
        //4. 对缩小范围的change用显意识流logic串起来;
        
        //5. 将类比到的数据构建与关联;
        
        //6. 进行思维mv循环
        
        //7. 进行决策输出
        
        
    }
}

-(void) setObject_Caches:(NSObject*)algsModel {
    //cacheShort
    [self.cacheShort addObject:algsModel];
    if (self.cacheShort.count > 8) {
        [self.cacheShort subarrayWithRange:NSMakeRange(self.cacheShort.count - 8, 8)];
    }
}

//found mv;
-(BOOL) checkHavMV:(NSDictionary*)dic{
    return [STRTOOK([DICTOOK(dic) objectForKey:@"urgentValue"]) floatValue] > 0;
}



//MARK:===============================================================
//MARK:                     < dataIn >
//MARK:===============================================================
-(void) dataIn:(NSObject*)algsModel{
    //1. 装箱
    NSArray *algsArr = [self dataIn_ConvertPointer:algsModel];
    
    //2. 检测imv
    BOOL findMV = [self dataIn_CheckMV:algsArr];
    
    //3. 分流
    AINetCMVModel *cmvModel;
    if (findMV) {
        cmvModel = [self dataIn_CreateCMVModel:algsArr];
    }else{
        [self dataIn_ToShortCache:algsArr];
    }
    
    //4. 联想
    if (findMV) {
        [self dataIn_AssociativeExperience:cmvModel];
    }else{
        [self dataIn_AssociativeData:algsArr];
    }
}

//转为指针数组(每个值都是指针)(在dataIn后第一件事就是装箱)
-(NSArray*) dataIn_ConvertPointer:(NSObject*)algsModel{
    NSArray *algsArr = [[AINet sharedInstance] getAlgsArr:algsModel];
    return algsArr;
    //1. 将索引的第二序列,提交给actionControl联想 (1. 作匹配测试  2. 只从强度最强往下);
}

-(void) testIndexReference{
//    for (AIKVPointer *pointer in algsArr) {
//        if (ISOK(pointer, AIKVPointer.class)) {
//
//            AIPort* (^ CreatePort)(NSInteger,NSInteger) = ^(NSInteger strongValue,NSInteger pointerId){
//                AIPortStrong *s1 = [[AIPortStrong alloc] init];
//                s1.value = strongValue;
//
//                AIPort *p1 = [AIPort newWithNode:[[AIActionControl shareInstance] insertModel:[AIIntModel newWithFrom:1 to:1] dataSource:@"testDS"]];
//                p1.strong = s1;
//                p1.pointer.pointerId = pointerId;
//                return p1;
//            };
//
//            AIPort *port46 = CreatePort(1,7);
//            [[AINet sharedInstance] setItemAlgsReference:pointer port:port46 difValue:1];
//            NSLog(@"");
//
//            //AIPort *port11 = CreatePort(1,1);
//            //AIPort *port12 = CreatePort(1,2);
//            //AIPort *port23 = CreatePort(2,3);
//            //AIPort *port34 = CreatePort(3,4);
//            //AIPort *port35 = CreatePort(3,5);
//            //AIPort *port36 = CreatePort(3,6);
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port11 difValue:1];
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port12 difValue:1];
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port23 difValue:1];
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port34 difValue:1];
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port35 difValue:1];
//            //[[AINet sharedInstance] setItemAlgsReference:pointer port:port36 difValue:1];
//
//            NSArray *referenceArr = [[AINet sharedInstance] getItemAlgsReference:pointer limit:3];
//            NSLog(@"");
//        }
//    }
}

//输入时,检测是否mv输入(饿或不饿)
-(BOOL) dataIn_CheckMV:(NSArray*)algsArr {
    BOOL findMV_UrgentValue = false;
    BOOL findMV_TargetType = false;
    for (AIKVPointer *pointer in algsArr) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            if ([@"urgentValue" isEqualToString:pointer.dataSource]) {
                findMV_UrgentValue = true;
            }else if ([@"targetType" isEqualToString:pointer.dataSource]) {
                findMV_TargetType = true;
            }
        }
    }
    return findMV_UrgentValue && findMV_TargetType;
}

//存到shortCache;
-(void) dataIn_ToShortCache:(NSArray*)algsArr{
    [self.cacheShort addObject:algsArr];
    if (self.cacheShort.count > 8) {
        [self.cacheShort removeObjectAtIndex:0];
    }
}

//联想到mv时,构建cmv模型;
-(AINetCMVModel*) dataIn_CreateCMVModel:(NSArray*)algsArr {
    AINetCMVModel *cmvModel = [[AINet sharedInstance] createCMV:algsArr order:self.cacheShort];
    [self.cacheShort removeAllObjects];
    return cmvModel;
}





-(void) dataIn_Decision___Temp{
    //可对shortCache数据作类比操作;
}


//联想相关数据(看到西瓜会开心)
-(void) dataIn_AssociativeData:(NSArray*)algsArr {
    if (ISOK(algsArr, NSArray.class)) {
        NSLog(@"noMv信号已输入完毕,联想");
        for (AIKVPointer *algs_kvp in algsArr) {
            NSArray *referPorts = [[AINet sharedInstance] getItemAlgsReference:algs_kvp limit:3];//在第二序列指向节点的端口;
            for (AIPort *referPort in referPorts) {
                if (ISOK(referPort, AIPort.class)) {
                    id referNode = [DBUtils searchObjectForPointer:referPort.pointer fileName:FILENAME_Node];
                    if (ISOK(referNode, AIFrontOrderNode.class)) {
                        //联想到cmv模型前因
                        AIFrontOrderNode *foNode = (AIFrontOrderNode*)referNode;
                        AINetCMVModel *cmvModel = [DBUtils searchObjectForPointer:foNode.cmvModel_kvp fileName:FILENAME_CMVModel];
                        AICMVNode *cmvNode = [DBUtils searchObjectForPointer:cmvModel.cmvNode_p fileName:FILENAME_Node];
                        NSLog(@"____联想结果:%@",cmvNode.pointer.algsType);
                    }else if(ISOK(referNode, AINode.class)){
                        //联想到数据网络节点
                        AINode *node = (AINode*)referNode;
                        NSLog(@"");
                    }
                    
                    NSLog(@"");
                    
                    //1. foNode.cmvModel_kvp为空  (bug)
                    //2. reference到底是指向foNode还是指向cmvModel.orders_kvp
                    //3. 
                    
                    
                    
                    
                }
            }
        }
    }
}

//从网络中找已有cmv经验(饿了找瓜)
-(void) dataIn_AssociativeExperience:(AINetCMVModel*)cmvModel {
    if (ISOK(cmvModel, AINetCMVModel.class)) {
        //cmv模型已形成,可取cmv的欲望值和迫切度值;
        //尝试抽象
        //尝试找imv的解决方案
        //1. 取cmvNode
        AICMVNode *cmvNode = [DBUtils searchObjectForPointer:cmvModel.cmvNode_p fileName:FILENAME_Node];
        AIFrontOrderNode *foNode = [DBUtils searchObjectForPointer:cmvModel.foNode_p fileName:FILENAME_Node];
        
        //2. 找到同样targetType的引用者
        if (ISOK(cmvNode, AICMVNode.class)) {
            NSArray *targetTypePorts = [[AINet sharedInstance] getItemAlgsReference:cmvNode.targetTypePointer limit:3];
            
            //3. 联想cmv模型
            for (AIPort *port in targetTypePorts) {
                id referNode = [DBUtils searchObjectForPointer:port.pointer fileName:FILENAME_Node];
                if (ISOK(referNode, AICMVNode.class)) {
                    AICMVNode *assCmvNode = (AICMVNode*)referNode;
                    
                    //4. 排除联想自己(随后写到reference中)
                    if (![cmvNode.pointer isEqual:assCmvNode.pointer]) {
                        AINetCMVModel *assCmvModel = [DBUtils searchObjectForPointer:assCmvNode.cmvModel_kvp fileName:FILENAME_CMVModel];
                        AIFrontOrderNode *assFoNode = [DBUtils searchObjectForPointer:assCmvModel.foNode_p fileName:FILENAME_Node];
                        
                        NSLog(@"____联想到cmv模型>>>\ncmvModel:%ld,%@ \n assCmvModel:%ld,%@",(long)cmvModel.pointer.pointerId,cmvModel.pointer.params,(long)assCmvModel.pointer.pointerId,assCmvModel.pointer.params);
                        
                        //5. 类比orders的规律,并abs;
                        NSMutableArray *sames = [[NSMutableArray alloc] init];
                        if (ISOK(foNode, AIFrontOrderNode.class) && ISOK(assFoNode, AIFrontOrderNode.class)) {
                            for (AIKVPointer *data_p in foNode.orders_kvp) {
                                //6. 是否已收集
                                BOOL already = false;
                                for (AIKVPointer *same_p in sames) {
                                    if ([same_p isEqual:data_p]) {
                                        already = true;
                                        break;
                                    }
                                }
                                //7. 未收集过,则查找是否有一致微信息(有则收集)
                                if (!already) {
                                    for (AIKVPointer *assData_p in assFoNode.orders_kvp) {
                                        if ([data_p isEqual:assData_p]) {
                                            [sames addObject:assData_p];
                                            break;
                                        }
                                    }
                                }
                                
                            }
                            
                            //8. 构建absNode
                            NSLog(@"____类比到规律——————————");
                            for (AIKVPointer *same in sames) {
                                NSLog(@"\n____>%ld",(long)same.pointerId);
                            }
                            AINetAbsNode *absNode = [[AINet sharedInstance] create:@[foNode,assFoNode] refs_p:sames];
                            
                            NSLog(@"构建抽象节点成功.....");
                        }
                    }
                }else if(ISOK(referNode, AINode.class)){
                    AINode *node = (AINode*)referNode;
                }
            }
        }
    }
    //[[AINet sharedInstance] searchNodeForDataType:nil dataSource:@"urgentValue"];
}

//类比处理(瓜是瓜)
-(void) dataIn_AnalogyData:(NSDictionary*)algsDic dataType:(NSString*)dataType{
    if (DICISOK(algsDic) && dataType) {
        
    }
}

//构建(想啥存啥)
-(void) dataIn_BuildNet{
    
}

@end
