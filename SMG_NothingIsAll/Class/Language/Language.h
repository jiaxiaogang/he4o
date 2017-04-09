//
//  LanguageUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------语言组织功能--------------------
 *  1,可到知识图谱中,记忆中查分词;
 *  2,不断提升Language对语言中的行为分解能力;
 *  3,不断提升Language对语言中的理解分析能力;
 *  4,不断提升Language对语言的组织输出能力;
 */
@class StoreModel_Text;
@interface Language : NSObject

/**
 *  MARK:--------------------语言输出能力--------------------
 */
-(NSString*) outputTextWithRequestText:(NSString*)requestText withStoreModel:(StoreModel_Text*)storeModel;


/**
 *  MARK:--------------------用于分析语言输入,并且找出规律词和图谱词并返回--------------------
 *
 */
-(NSArray*) inputTextWithRequestText:(NSString*)requestText;

@end
