//
//  Understand.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理解功能--------------------
 *  1,text
 *      1.1,把输入语言和MemStore比较 找到分词 交给MK.words
 *      1.2,把输入分词和MemStore中Do比较 分析分词的意思 交给MK.words.do;
 *  2,image
 *      ...类似text的理解方式;只是处理对象不是word而是感觉码;
 *  3,audio
 *      ...类似text的理解方式;
 *
 */
@interface Understand : NSObject


@property(strong,nonatomic)NSTimer* timer;//10秒思考一次;

-(id) init;

//MARK:--------------------开始思考人生--------------------
-(void) startUnderstand;


/**
 *  MARK:--------------------text部分--------------------
 *  用于text的理解
 */
//MARK:--------------------text部分--------------------
-(NSArray*) analyzeText:(NSString*)text;




@end
