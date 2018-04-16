//
//  AINode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < AINode >
//MARK:参考:n10p14等;
//MARK:===============================================================
@class AIKVPointer,AIAlgsPointer,AICMVModel;
@interface AINode : NSObject<NSCoding>

@property (strong,nonatomic) AIKVPointer *pointer;          //数据指针(自身指针地址)

//是什么(定义)
@property (strong,nonatomic) NSMutableArray *absPorts;      //抽象指向(多继承,接口等）
@property (strong,nonatomic) NSMutableArray *conPorts;      //具象指向
//的什么(关系)
@property (strong,nonatomic) NSMutableArray *propertyPorts; //属性
@property (strong,nonatomic) NSMutableArray *bePropertyPorts;
//能什么(变化)
@property (strong,nonatomic) NSMutableArray *changePorts;   //变化
@property (strong,nonatomic) NSMutableArray *beChangePorts;
//动因模型,的前序列(判断:判断dT&dS) (有logicPorts的node必然其data是AICMVModel类型的)
@property (strong,nonatomic) NSMutableArray *logicPorts;    //前因
@property (strong,nonatomic) NSMutableArray *beLogicPorts;  //导致了cmv变化

@end
