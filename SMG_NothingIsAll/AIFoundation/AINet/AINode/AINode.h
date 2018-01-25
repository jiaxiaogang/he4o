//
//  AINode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

//MARK:===============================================================
//MARK:                     < AINodeBase >
//MARK:参考:n10p14等;
//MARK:===============================================================
@class AIKVPointer;
@interface AINodeBase : NSObject<NSCoding>

//@property (assign, nonatomic) AINodeDataType dataType;
@property (strong,nonatomic) AIKVPointer *pointer; //数据指针(自身指针地址)
@property (strong,nonatomic) NSMutableArray *subPorts;      //子类
@property (strong,nonatomic) NSMutableArray *propertyPorts; //属性
@property (strong,nonatomic) NSMutableArray *methodPorts;   //方法

@end


//MARK:===============================================================
//MARK:                     < AINode >
//MARK:===============================================================
@interface AINode : AINodeBase

@property (strong,nonatomic) NSMutableArray *isAPorts;      //父类(多继承）

@end


//MARK:===============================================================
//MARK:                     < AIIntanceNode >
//MARK:===============================================================
@interface AIIntanceNode : AINodeBase

@property (strong,nonatomic) AIKVPointer *instanceOf;

@end


//MARK:===============================================================
//MARK:                     < AIPropertyNode >
//MARK:===============================================================
@interface AIPropertyNode : AINodeBase

@property (strong,nonatomic) AIKVPointer *isClass;//指向subNode
@property (strong,nonatomic) AIKVPointer *valueIs;//指向instanceNode

@end


//MARK:===============================================================
//MARK:                     < AIMethodNode >
//MARK:===============================================================
@interface AIMethodNode : AINodeBase

@property (strong,nonatomic) NSMutableArray *resultPorts;
@property (strong,nonatomic) AIKVPointer *target;

@end


//MARK:===============================================================
//MARK:                     < AIChangeNode >
//MARK:===============================================================
@interface AIChangeNode : AINodeBase

@property (assign,nonatomic) CGFloat fromValue;
@property (assign,nonatomic) CGFloat toValue;
@property (strong,nonatomic) AIKVPointer *target;

@end
