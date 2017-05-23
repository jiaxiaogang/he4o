//
//  MemModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  MARK:--------------------基于可类比推理的记忆结构复杂度较高--------------------
 *  故:先研究类比推理的几大难题,研究下后,可能单独给类比推理开个项目;也可以在NothingIsAll上面继续开发;
 *  有一种叫"无知识"学习的机器学习,估计在实现上与我的NothingIsAll是有异曲同工之处的;但他的理念只是"无知识"学习,并没有指出AI其它方面的"无";
 */
@class ObjModel,DoModel,CharModel;
@interface MemModel : NSObject

@property (assign, nonatomic) NSInteger groupId;//当前分组id;

//@property (assign, nonatomic)  <#valName#>;
@property (assign, nonatomic) NSInteger charRowId;
@property (assign, nonatomic) NSInteger  objRowId;
@property (assign, nonatomic) NSInteger  doRowId;
@property (assign, nonatomic) NSInteger  targetObjRowId;
//@property (assign, nonatomic) NSInteger groupModel;//记忆间的互相引用;如:(A看到B在看着A)

@end
