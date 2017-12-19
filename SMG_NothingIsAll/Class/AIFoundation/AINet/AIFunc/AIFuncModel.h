//
//  AIFuncModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------Function算法函数等"反射节点"模型--------------------
 *
 *  注://铁的硬度是多少米?(当尺寸返回值,与参数"硬度")输入时,我们知道其参数类型是不匹配的;所以,这里可以明确定义要求的参数类型,返回值类型;
 */
@interface AIFuncModel : AIObject

@property (assign, nonatomic) Class funcClass;  //方法所在类名
@property (assign, nonatomic) SEL funcSel;      //方法本体
@property (assign, nonatomic) NSInteger version;//版本号
@property (assign, nonatomic) NSString *ID;     //ClassName+方法序数 || 全局方法序数


//MARK:===============================================================
//MARK:                     < Method >
//MARK:===============================================================
/**
 *  MARK:--------------------参数类型--------------------
 */
-(Class) paramClass;


/**
 *  MARK:--------------------返回值类型--------------------
 */
-(Class) valueClass;


/**
 *  MARK:--------------------执行--------------------
 */
-(id) run:(NSArray*)args;

@end
