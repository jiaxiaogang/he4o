//
//  MKStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------知识图谱--------------------
 *  MK是Mem被Understand加工后的结果;(对比如下:)
 *  同时出现为MK
 *  先后出现为Logic
 *
 *  注:
 *      1,可以被GC从dic回收到local;甚至删掉;
 *      2,MK是被Understand生成,更可信,更稳定,明确mind值;
 */
@interface MKStore : NSObject


/**
 *  MARK:--------------------Text--------------------
 *  调用转到Text;
 */
-(BOOL) containerWord:(NSString*)word;//图谱分词数组;包含某词;
-(BOOL) containerWordWithWhere:(NSDictionary*)where;//根据其它字段找某词;
-(NSDictionary*) getWord:(NSString*)word;//图谱分词数组;包含某词;
-(NSDictionary*) getWordWithWhere:(NSDictionary*)where;//根据其它字段找某词;
-(NSMutableArray*) getWordArrWithWhere:(NSDictionary*)where;//根据where找所有词
-(NSDictionary*) addWord:(NSString*)word;
-(NSMutableArray*) addWordArr:(NSArray*)wordArr;
-(NSDictionary*) addWord:(NSString*)word withObjId:(NSString*)objId withDoId:(NSString*)doId;

/**
 *  MARK:--------------------objModel--------------------
 */
-(NSDictionary*) getObj:(NSString*)itemName;
-(NSDictionary*) getObjWithWhere:(NSDictionary*)where;
-(NSMutableArray*) getObjArrWithWhere:(NSDictionary*)where;//根据where找所有
-(NSDictionary*) addObj:(NSString*)itemName;
-(NSMutableArray*) addObjArr:(NSArray*)itemNameArr;


/**
 *  MARK:--------------------doModel--------------------
 */
-(NSDictionary*) getDo:(NSString*)itemName;
-(NSDictionary*) getDoWithWhere:(NSDictionary*)where;
-(NSMutableArray*) getDoArrWithWhere:(NSDictionary*)where;//根据where找所有
-(NSDictionary*) addDo:(NSString*)itemName;
-(NSMutableArray*) addDoArr:(NSArray*)itemNameArr;




/**
 *  MARK:--------------------分析知识图谱的归类--------------------
 *  1,先天不知道人类
 *  2,类并不是类;只是有相同特征的一些东西;(类,限制了灵活性,而人工智能要求最大的灵活性,所以);
 *  3,观察每个个体与共同点;
 *  思考:小说中出现小芳,思考,小说里的小芳是个人类;但不是我认识的那个小芳;
 */
-(void) addPerson;//临时,,随后删掉(3d图像对实物的描述)


@end
