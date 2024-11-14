//
//  TCRethink.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------inSP更新器--------------------
 *  @desc 分裂成理性反省 和 感性反省 (参考n24p02);
 *  @desc 四个feedback分别对应四个rethink反省 (参考25031-12);
 *  @version
 *      2024.08.31: 废弃perceptOutRethink()和reasonOutRethink(),因为这个早被OutSPDic替代了,只是现在才删这些无用的代码);
 */
@interface TCRethink : NSObject

+(void) reasonInRethink:(AIMatchFoModel*)model cutIndex:(NSInteger)cutIndex type:(AnalogyType)type;
+(void) perceptInRethink:(AIMatchFoModel*)model type:(AnalogyType)type;

@end
