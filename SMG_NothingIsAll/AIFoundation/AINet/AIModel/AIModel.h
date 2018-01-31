//
//  AIModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

/**
 *  MARK:--------------------存AIDataNode的数据模型--------------------
 *  AIModel是Algs的算法结果集Model;
 *  参考:n9p9 AINet(数据模型)
 */
@interface AIModel : NSObject<NSCoding>

@end


//MARK:===============================================================
//MARK:                     < AIIntModel >
//MARK:===============================================================
@class AIAlgsPointer;
@interface AIIntModel : AIModel

@property (assign,nonatomic) CGFloat from;
@property (assign,nonatomic) CGFloat to;
@property (strong,nonatomic) AIAlgsPointer *algs;

@end

//MARK:===============================================================
//MARK:                     < AIFloatModel >
//MARK:===============================================================
@interface AIFloatModel : AIModel

@property (assign,nonatomic) CGFloat from;
@property (assign,nonatomic) CGFloat to;
@property (strong,nonatomic) AIAlgsPointer *algs;

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

@property (strong,nonatomic) NSMutableArray *string;//char的pointer组成的数组

@end

//*  mp3
//*  mp4
//*  imv     //所有imv定义的子类...

