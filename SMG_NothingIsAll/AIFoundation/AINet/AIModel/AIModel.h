//
//  AIModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------Net.data的数据类型--------------------
 *  int     //from to algs
 *  float   //from to algs
 *  change  //from to
 *  file    //二进制文件
 *  char
 *  string  //char的pointer组成的数组
 *  mp3
 *  mp4
 *  imv     //所有imv定义的子类...
 *  参考:n9p9 n10p23
 */
@interface AIModel : NSObject<NSCoding>

@end


//MARK:===============================================================
//MARK:                     < AIIntModel >
//MARK:===============================================================
@class AIAlgsPointer;
@interface AIIntModel : AIModel

+(AIIntModel*) newWithFrom:(int)from to:(int)to;
@property (assign,nonatomic) int from;
@property (assign,nonatomic) int to;
@property (strong,nonatomic) AIAlgsPointer *algs;

@end

//MARK:===============================================================
//MARK:                     < AIFloatModel >
//MARK:===============================================================
@interface AIFloatModel : AIModel

+(AIFloatModel*) newWithFrom:(CGFloat)from to:(CGFloat)to;
@property (assign,nonatomic) CGFloat from;
@property (assign,nonatomic) CGFloat to;
@property (strong,nonatomic) AIAlgsPointer *algs;//随后删掉(由AINode.dataSource标记AIInputModel.PropertyName替代,并且algs的pointer不应出现在存储层)

@end

//MARK:===============================================================
//MARK:                     < AIChangeModel >
//MARK:===============================================================
@interface AIChangeModel : AIModel

@property (assign,nonatomic) CGFloat from;
@property (assign,nonatomic) CGFloat to;

@end


//MARK:===============================================================
//MARK:                     < AIFileModel >
//MARK:===============================================================
@interface AIFileModel : AIModel

@property (strong,nonatomic) NSData *file;

@end


//MARK:===============================================================
//MARK:                     < AICharModel >
//MARK:===============================================================
@interface AICharModel : AIModel

@property (assign,nonatomic) char c;

@end

//MARK:===============================================================
//MARK:                     < AIStringModel >
//MARK:===============================================================
@interface AIStringModel : AIModel

@property (strong,nonatomic) NSMutableArray *charPointers;//char的pointer组成的数组

@end

//MARK:===============================================================
//MARK:                     < AIIdentifierModel >
//MARK:===============================================================
@interface AIIdentifierModel : AIModel

+(AIIdentifierModel*) newWithIdentifier:(NSString*)identifier;
@property (strong,nonatomic) NSString *identifier;//自定义类类别标记(如AIImvAlgsModel)

@end

//*  mp3
//*  mp4
//*  imv     //所有imv定义的子类...

