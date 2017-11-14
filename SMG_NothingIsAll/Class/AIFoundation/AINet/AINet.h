//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINet : NSObject

//MARK:===============================================================
//MARK:                     < String反射区 >
//MARK:===============================================================
-(void) commitString:(NSString*)str;


//MARK:===============================================================
//MARK:                     < AIObject反射区(内感) >
//MARK:===============================================================
-(void) commitModel:(AIObject*)model;


//MARK:===============================================================
//MARK:                     < 建设input对接net功能区 >
//MARK:===============================================================
-(void) addStringNode:(AIKVPointer*)kvPointer;

@end
