//
//  AINetService.m
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/21.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "AINetService.h"
#import "AINetUtils.h"
#import "AIAlgNodeBase.h"
#import "TOUtils.h"

@implementation AINetService

/**
 *  MARK:--------------------获取GLAlg--------------------
 *  @desc SP经历的啥时反向反馈类比,所以大概念上,无法找到GL,我们需要从两条线出发:
 *          1. SP的生成线 (可记录下针对地址);
 *          2. GL的生成线 (可记录下针对地址);
 *        从中,找出交叠,比如,看下SP中的坚果,与GL生成时的坚果,之间的网络关系是什么? (可用网络可视化查);
 *  @bug
 *      2020.06.16: 找不到glAlg的bug;
 *  @todo
 *      2020.06.24: 对alg指引联想,取同层+多层abs,比如,我没洗过西瓜,但我洗过苹果,或者洗过水果,那我可以试下用水洗西瓜;
 *      2020.11.07: 返回结果,按短时记忆局部匹配度排序 (比如饿了,优先想到几秒前看到过的香蕉);
 *                  注:这步未必需要,因为太复杂,况且在决策循环中,也会有类似实现,且是分解后的;
 *  @version
 *      2020.11.06: 核对21115逻辑没问题 & 直接取返回relativeFo_ps;
 *  @result : 返回relativeFo_ps,用backConAlg节点,由此节点取refPorts,再筛选type,可取到glFo经历;
 */
+(NSArray*) getInner1Alg:(AIAlgNodeBase*)pAlg vAT:(NSString*)vAT vDS:(NSString*)vDS type:(AnalogyType)type{
    //1. 数据检查hAlg_根据type和value_p找ATHav
    if (Log4GetInnerAlg) NSLog(@"--> getInnerAlg:%ld ATDS:%@&%@ 参照:%@(C和参照概念有mIsC关联则成功)",(long)type,vAT,vDS,Alg2FStr(pAlg));
    AIKVPointer *innerValue_p = [theNet getNetDataPointerWithData:@(type) algsType:vAT dataSource:vDS];
    
    //2. 对v.ref和a.abs进行交集,取得有效GLAlg;
    NSArray *gl_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Value:innerValue_p]];
    
    //3. 找出合格的inner1Alg;
    int debugVesion = 1;
    for (AIKVPointer *gl_p in gl_ps) {
        AIAlgNodeBase *glAlg = [SMGUtils searchNode:gl_p];
        
        //4. 根据glAlg,向具象找出真正当时变"大小"的具象概念节点;
        NSArray *glAlgCon_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:glAlg]];
        
        //5. 这些节点中,哪个与pAlg有抽具象关系,就返回哪个;
        for (AIKVPointer *glAlgCon_p in glAlgCon_ps) {
            if (Log4GetInnerAlg) NSLog(@"-> try_getInnerAlg结果B:%@ 结果具象C:%@",Alg2FStr(glAlg),AlgP2FStr(glAlgCon_p));
            if ([TOUtils mIsC_2:glAlgCon_p c:pAlg.pointer] || [TOUtils mIsC_2:pAlg.pointer c:glAlgCon_p]) {
                
                //6. 用mIsC有效的glAlg具象指向节点,向refPorts取到relativeFos返回;
                NSArray * relativeFoPorts = [SMGUtils filterPorts:[AINetUtils refPorts_All4Alg:glAlg] havTypes:@[@(type)] noTypes:nil];
                NSArray *relativeFo_ps = [SMGUtils convertPointersFromPorts:ARR_SUB(relativeFoPorts, 0, cHavNoneAssFoCount)];
                return relativeFo_ps;
            }
            
            //7. 将结果,先按照短时记忆(除末位外)局部匹配度排序,再返回 (未必需要,参考注释todo20201107);
            //5. 取hAlg的refs引用时序大全 (空想集,即如何获取hAlg);
            //NSMutableArray *partFos = [[NSMutableArray alloc] init];
            //for (NSInteger i = 0; i < theTC.inModelManager.models.count; i++) {
            //    AIShortMatchModel *model = ARR_INDEX_REVERSE(theTC.inModelManager.models, i);
            //
            //    //6. 遍历入短时记忆,根据matchAlg取refs (此处应该是希望Hav不要脱离短时记忆,所以用M.refPorts取交集);
            //    NSArray *mRef_ps = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg:model.matchAlg]];
            //
            //    //7. 对hRefs和mRefs取交集;
            //    NSArray *hmRef_ps = [SMGUtils filterSame_ps:hRef_ps parent_ps:mRef_ps];
            //    hmRef_ps = ARR_SUB(hmRef_ps, 0, cHavNoneAssFoCount);
            //
            //    //8. 收集 (交集优先部分);
            //    [partFos addObjectFromArray:[SMGUtils collectArrA_NoRepeat:partFos arrB:hmRef_ps]];
            //}
            ////9. 收集 (其余空想部分) (考虑下二者是否应该取交集?);
            //relativeFos = [SMGUtils collectArrA_NoRepeat:relativeFos arrB:partFos];
        }
    }
    return nil;
}

@end
