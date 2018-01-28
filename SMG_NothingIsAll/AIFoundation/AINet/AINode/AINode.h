//
//  AINode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

//MARK:===============================================================
//MARK:                     < AINode >
//MARK:参考:n10p14等;
//MARK:===============================================================
@class AIKVPointer,AIAlgsPointer;
@interface AINode : NSObject<NSCoding>

@property (strong,nonatomic) AIKVPointer *pointer;          //数据指针(自身指针地址)
@property (strong,nonatomic) NSString *dataType;            //data的数据类型
//是(定义)
@property (strong,nonatomic) NSMutableArray *absPorts;      //抽象指向(多继承,接口等）
@property (strong,nonatomic) NSMutableArray *conPorts;      //具象指向
//的(关系)
@property (strong,nonatomic) NSMutableArray *propertyPorts; //属性
@property (strong,nonatomic) NSMutableArray *bePropertyPorts; //属性
//能(变化)
@property (strong,nonatomic) NSMutableArray *changePorts;   //变化
@property (strong,nonatomic) NSMutableArray *logicPorts;    //方法

@end


//MARK:===============================================================
//MARK:                     < AIValueNode >
//MARK:===============================================================
@interface AIValueNode : AINode

@property (assign,nonatomic) CGFloat from;
@property (assign,nonatomic) CGFloat to;
@property (strong,nonatomic) AIAlgsPointer *algs;   

@end


//MARK:===============================================================
//MARK:                     < AILogicNode >
//MARK:===============================================================
@interface AILogicNode : AINode

@property (strong,nonatomic) NSMutableArray *resultPorts;
@property (strong,nonatomic) AIKVPointer *target;

@end


//MARK:===============================================================
//MARK:                     < AIChangeNode >
//MARK:===============================================================
@interface AIChangeNode : AINode

@property (assign,nonatomic) CGFloat fromValue;
@property (assign,nonatomic) CGFloat toValue;
@property (strong,nonatomic) AIKVPointer *target;

@end



//@property (assign, nonatomic) AINodeDataType dataType;
