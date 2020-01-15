//
//  TIRUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/1/10.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TIRUtils.h"

@implementation TIRUtils

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 *  要求: protoFo必须全含assFo对应的last匹配下标之前的所有元素;
 *  例如: 如: protFo:[abcde] 全含 assFo:[acefg]
 *  名词说明:
 *      1. 全含: 指从lastAssIndex向前,所有的assItemAlg都匹配成功;
 *      2. 非全含: 指从lastAssIndex向前,只要有一个assItemAlg匹配失败,则非全含;
 *  @param success : lastAssIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1);
 *  @param protoFo : 四层说明: 在fromShortMem时,protoFo中的概念元素为parent层, 而在fromRethink时,其元素为match层;
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo checkItemValid:(BOOL(^)(AIKVPointer *itemAlg,AIKVPointer *assAlg))checkItemValid success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success failure:(void(^)(NSString *msg))failure {
    //1. 数据准备;
    BOOL paramValid = protoFo && protoFo.content_ps.count > 0 && assFo && assFo.content_ps.count > 0 && success && checkItemValid;
    if (!paramValid) {
        failure(@"参数错误");
        return;
    }
    AIKVPointer *lastProtoAlg_p = ARR_INDEX_REVERSE(protoFo.content_ps, 0); //最后一个protoAlg指针
    int validItemCount = 1;                                                 //默认有效数为1 (因为lastAlg肯定有效);
    NSInteger lastAssIndex = -1;                                            //在assFo已发生到的index,后面为预测;
    NSInteger lastProtoIndex = protoFo.content_ps.count - 2;                //protoAlg匹配判断从倒数第二个开始,向前逐个匹配;
    
    //2. 找出lastIndex
    for (NSInteger i = 0; i < assFo.content_ps.count; i++) {
        NSInteger curIndex = assFo.content_ps.count - i - 1;
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, curIndex);
        if (checkItemValid(lastProtoAlg_p,checkAssAlg_p)) {
            lastAssIndex = curIndex;
            break;
        }
    }
    if (lastAssIndex == -1) {
        failure(@"时序识别: lastItem匹配失败,查看是否在联想时就出bug了");
        return;
    }else{
        NSLog(@"时序识别: lastItem匹配成功");
    }
    
    //3. 从lastAssIndex向前逐个匹配;
    for (NSInteger i = lastAssIndex - 1; i >= 0; i--) {
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, i);
        if (checkAssAlg_p) {
            
            //4. 在protoFo中同样从lastProtoIndex依次向前找匹配;
            BOOL checkResult = false;
            for (NSInteger j = lastProtoIndex; j >= 0; j--) {
                AIKVPointer *protoAlg_p = ARR_INDEX(protoFo.content_ps, j);
                if (checkItemValid(protoAlg_p,checkAssAlg_p)) {
                    lastProtoIndex = j; //成功匹配alg时,更新protoIndex (以达到只能向前匹配的目的);
                    checkResult = true;
                    validItemCount ++;  //有效数+1;
                    NSLog(@"时序识别: item有效+1");
                    break;
                }
            }
            
            //5. 非全含 (一个失败,全盘皆输);
            if (!checkResult) {
                failure(@"时序识别: item无效,未在protoFo中找到,所有非全含,不匹配");
                return;
            }
        }
    }
    
    //6. 到此全含成功 之: 匹配度计算
    CGFloat matchValue = (float)validItemCount / assFo.content_ps.count;
    
    //7. 到此全含成功 之: 返回success
    success(lastAssIndex,matchValue);
}

@end
