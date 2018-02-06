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
@class AIKVPointer,AIAlgsPointer;
@interface AINode : NSObject<NSCoding>

@property (strong,nonatomic) AIKVPointer *pointer;          //数据指针(自身指针地址)
@property (strong,nonatomic) NSString *dataType;            //AIData的Type(一般为AIIntModel,AIIndentifier等)
@property (strong,nonatomic) NSString *dataSource;          //AIData的来源(一般为inputModel中的某属性)

//是什么(定义)
@property (strong,nonatomic) NSMutableArray *absPorts;      //抽象指向(多继承,接口等）
@property (strong,nonatomic) NSMutableArray *conPorts;      //具象指向
//的什么(关系)
@property (strong,nonatomic) NSMutableArray *propertyPorts; //属性
@property (strong,nonatomic) NSMutableArray *bePropertyPorts;
//能什么(变化)
@property (strong,nonatomic) NSMutableArray *changePorts;   //变化
@property (strong,nonatomic) NSMutableArray *beChangePorts;
//干什么(先后)
@property (strong,nonatomic) NSMutableArray *logicPorts;    //时因指向
@property (strong,nonatomic) NSMutableArray *beLogicPorts;  //后果指向

@end

