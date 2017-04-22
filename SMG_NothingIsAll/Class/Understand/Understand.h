//
//  Understand.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理解系统--------------------
 *  理解系统理解的是与世界的交互;(包括文字,情感,图像,声音等)
 *
 *  A:行为与文字的映射;
 *  注:找到同时发生的规律,将其关联;
 *      1,text
 *          1.1,把输入语言和MemStore比较 找到分词 交给MK.words
 *          1.2,把输入分词和MemStore中Do比较 分析分词的意思 交给MK.words.do;
 *      2,image
 *          ...类似text的理解方式;只是处理对象不是word而是感觉码;
 *      3,audio
 *          ...类似text的理解方式;
 *  B:行为与图形的映射;
 *  C:行为与听到的声音的映射;
 *
 *
 *  D:逻辑因果关系;
 *  注:找出逻辑关系的规律,将其记录;
 *
 */
@class FeelModel,DoModel;
@interface Understand : NSObject


@property(strong,nonatomic)NSTimer* timer;//10秒思考一次;


//1,Input->Feel->Understand(Do)->Memory(MemStore,MKStore,LogicStore)
@property (strong,nonatomic) NSString *doType;



-(id) init;

-(void) commitFeelModel:(FeelModel*)model;
//使用信息对应行为输入;
-(void) commitWithFeelModel:(FeelModel*)feelModel withDoModel:(DoModel*)doModel;

//MARK:--------------------开始思考人生--------------------
-(void) startUnderstand;


/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
//MARK:--------------------text部分--------------------
-(NSArray*) analyzeText:(NSString*)text;


/**
 *  MARK:--------------------行为<-->文字--------------------
 */








@end
