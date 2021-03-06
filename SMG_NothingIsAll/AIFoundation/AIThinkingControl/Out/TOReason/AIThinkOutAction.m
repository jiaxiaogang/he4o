//
//  TOAlgScheme.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutAction.h"
#import "AIAbsAlgNode.h"
#import "ThinkingUtils.h"
#import "AINetUtils.h"
#import "AINetService.h"
#import "ShortMatchManager.h"
#import "AIShortMatchModel.h"
#import "TOFoModel.h"
#import "TOAlgModel.h"
#import "TOValueModel.h"
#import "TOUtils.h"
#import "AIPort.h"
#import "AIScore.h"
#import "ReasonDemandModel.h"
#import "PerceptDemandModel.h"
#import "AIMatchFoModel.h"
#import "AINetIndex.h"
#import "DemandManager.h"

@implementation AIThinkOutAction

/**
 *  MARK:--------------------对一个rangeOrder进行行为化;--------------------
 *  @desc 一些记录:
 *      1. 191105总结下,此处有多少处,使用短时,长时,在前面插入瞬时;
 *      2. 191105针对概念嵌套的代码,先去掉;
 *      3. 191107考虑将foScheme也搬过来,优先使用matchFo做第一解决方案;
 *  @TODO_TEST_HERE: 测试下阈值-3,是否合理;
 *  @version
 *      2020.12.15: _Fo统一由fo.begin调用 (参考21183:将RelativeFos改为逐个返回,21184:Fo流程控制);
 *      2020.12.16: HNGL类型Fo节点的末位也照片行为化,因为_Hav中有处理其为ActYes (参考_Hav第0级);
 *      2020.12.18: _Fo的下帧跳转,也交由此处来完成;
 *      2020.12.18: 仅在首帧时,进行感性反思评价;
 *      2020.12.25: 未发生理性评价 (range为空 & hngl节点 & 空S = 不通过) (参考21186 & 21188 & 21202);
 *      2020.12.26: 未发生理性评价,改为 (hngl节点 & 空S = 不通过) (参考21205);
 *      2020.12.18: 仅首帧,进行评价;
 *      2021.01.22: R-任务解决方案不做空S评价;
 *      2021.01.22: R-任务直接解决方案不做反思,因为它评价必不通过;
 *      2021.04.13: 所有fo都进行反思: (1.R-下挂mv0的fo; 2.P-下挂mv+的fo; 3.HNGL未指向mv),三者都可进行反思;
 *      2021.05.28: 反思子任务要防止与已有父级R任务重复 (避免子任务死循环) (参考23092);
 *      2021.06.01: 反思子任务死循环再现 (参考23094);
 *      2021.06.01: 对已有的failure状态子任务,加入到子任务不应期中,避免明明无计可施的R子任务还不断尝试 (参考23095);
 *      2021.06.04: 把子任务生成,重构到DemandManager中 (参考23096);
 *      2021.07.17: 废弃FRSTime评价 (参考n23p18);
 */
-(void) convert2Out_Fo:(TOFoModel*)outModel{
    //1. 取出需行为化的content_ps部分;
    AIFoNodeBase *curFo = [SMGUtils searchNode:outModel.content_p];
    
    //2. 数据检查
    NSLog(@"\n\n=============================== 行为化Fo ===============================\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),[NSLog_Extension convertATType2Desc:[curFo.pointer.dataSource integerValue]]);
    if (curFo == nil || !ARRISOK(curFo.content_ps)) {
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
        return;
    }
    
    //3. 对P任务首帧执行前做评价_2021.01.22: R-任务解决方案不做空S评价;
    if (outModel.actionIndex == -1 && !ISOK(outModel.baseOrGroup, ReasonDemandModel.class)) {
        //5. 未发生理性评价 (空S评价);
        BOOL reasonScore =  [AIScore FRS:curFo];
        if (!reasonScore) {
            NSLog(@"未发生理性评价(空S)-不通过");
            outModel.status = TOModelStatus_ScoreNo;
            [self.delegate toAction_SubModelFailure:outModel];
            return;
        }
    }
    
    //3. 对HNGL任务首帧执行前做评价;
    if (outModel.actionIndex == -1) {
        //4. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
        AIShortMatchModel *rtInModel = [theTC to_Rethink:outModel];
        
        //5. 提交子任务;
        __block NSArray *except_ps = nil;
        [DemandManager updateSubDemand:rtInModel baseFo:outModel createSubDemandBlock:^(ReasonDemandModel *subDemand) {
            
            //6. 子任务行为化;
            [self.delegate toAction_SubModelBegin:subDemand];
            //return;//子任务Finish/ActYes时,不return,因为要继续父任务;
        } finishBlock:^(NSArray *_except_ps) {
            except_ps = _except_ps;
        }];
        
        //8. 子任务尝试完成后,进行FPS综合评价 (如果子任务完成后,依然有解决不了的不愿意的价值,则不通过);
        BOOL scoreSuccess = [AIScore FPS:outModel rtInModel:rtInModel except_ps:except_ps];
        NSLog(@"未发生感性评价(反思)-%@",scoreSuccess ? @"通过 (继续父fo行为化)" : @"不通过 (中断父fo行为化)");
        if (!scoreSuccess) {
            outModel.status = TOModelStatus_ScoreNo;
            [self.delegate toAction_SubModelFailure:outModel];
            return;
        }
    }
    
    //4. 跳转下帧,
    if (outModel.actionIndex < curFo.count - 1) {
        //a. Alg转移 (下帧)
        outModel.actionIndex ++;
        AIKVPointer *move_p = ARR_INDEX(curFo.content_ps, outModel.actionIndex);
        TOAlgModel *moveAlg = [TOAlgModel newWithAlg_p:move_p group:outModel];
        NSLog(@"_Fo行为化第 %ld/%ld 个: %@",(long)outModel.actionIndex,(long)curFo.count,Fo2FStr(curFo));
        [self.delegate toAction_SubModelBegin:moveAlg];
    }else{
        //c. 成功,递归 (参考流程控制Finish的注释version-20200916 / 参考22061-7);
        outModel.status = TOModelStatus_ActYes;
        NSLog(@"_Fo行为化: Finish %ld/%ld 到ActYes",(long)outModel.actionIndex,(long)curFo.count);
        [self.delegate toAction_SubModelActYes:outModel];
    }
}

/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: MC匹配PM行为化 (M为实概念-来自inModel,C为虚概念-来自TO解决方案);
 *  第3级: LongNet长短时网络行为化
 *  _param curAlg_p : 三个来源: 1.Fo的元素A;  2.Range的元素A; 3.Alg的嵌套A;
 *  @version
 *      2020-05-22 : 支持更发散的联想(要求matchAlg和hAlg同被引用),因每次递归都要这么联想,所以从TOP搬到这来 (由19152改成19192);
 *      2020-05-27 : 支持outModel (目前cHav方法,收集所有acts,一次性返回行为,而并未进行多轮外循环,所以此处不必做subOutModel);
 *      2020-07-05 : 支持MC匹配,优先级小于isOut=true,大于RelativeFos;
 *      2020-07-06 : PM本质上是多态修正方法,所以不能将C作为M传过去,改为将M传过去;
 *      2020-07-07 : RelativeFo最后一位,不用行为化;
 *      2020-07-08 : 删掉HNGL调用递归,因为HNGL不是完成,外循环input回来,才算完成,(如飞了一步,还要继续飞)(如下了蛋,得看到蛋),参考20081;
 *      2020-07-27 : hAlg的获取方案relativeFos,由纯理性交集(参考19192),改为优化取理性交集,其次取纯空想 (因为常无法一蹴而就,需递归判定,但又不得不承认,有时候确实可以一蹴而就,比如在家时有冰箱,就不用想回京吃外卖);
 *      2020.08.22 : HNGL时,仅设定status=ActYes,等待外循环返回"理性符合的HNGL"结果;
 *      2020.11.23 : PM理性评价结果,之后的逻辑改动 (参考21147);
 *      2020.12.16 : 将第0级,isHNGL判断,改为先判断baseFo是HNGL,然后alg是末位,则说明是hnglAlg (参考21115-glConAlg并不是ATGL);
 *      2020.12.17 : getInnerAlg改为返回单条,此处调用支持,并并入流程控制fo.begin (参考21183);
 *      2021.01.22 : 支持R-模式的S类型Alg满足 (参考22061);
 *      2021.01.23 : 将R-模式改为调用PM满足 (参考22061-改4);
 &      2021.01.31 : R-模式V3迭代:将原R-模式彻底整合到原有流程中 (参考22105示图);
 *      2021.03.11 : R-模式理性静默成功迭代 (参考22153);
 *      2021.05.13 : 不应期常切断决策流程的BUG: 将reModel的matchA改成protoA,并将不应期也改为有protoA来判断防重 (参考23076);
 *      2021.05.20 : 在mIsC判断中,仅对actNo的做为不应期 (参考23079);
 *  @todo
 *      2020.07.05: 在下面MC中,转至PM时,是将C作为M的,随后需测下,看是否需要独立对MC做类似PM的理性评价,即将一步到位,细化成两步各自评价;
 *      2021.01.04: 支持APS评价 (以前原本支持替换Alg并反思fo,后来弃用了?代码找不到) (参考22012);
 *  @bug
 *      2020.09.15: 将isOut=true时,改为调Finish,因为目前ActYes暂不对行为输出做处理,但流程控制要继续推进,否则会BUG (参考21025);
 *      2020.09.22: 取消行为输出时直接调用Finish,因为在OPushM中也会推进流程控制,如果这里再调用,会重复触发反省类比 (参考21042);
 *      2020.09.28: 独特码取到的不是最新帧,导致反省类比P时,不是距0而是距6,将mIsC的for循环改为新帧优先即可 (参考21054);
 *      2020.11.11: 修复cIsM导致mIsC判断失败的BUG (参考21143);
 *      2020.11.18: mIsC不稳定BUG,将mIsC改为对matchAlgs依次判断 (参考21145);
 *      2020.12.24: isHNGL判断isL写错,导致L时无法触发ActYes与反省类比 (参考isHNGL方法) `T`;
 *      2021.03.15: R-静默成功模式中,mIsC判断将1层改为2层 (参考22163);
 *      2021.04.11: getInnerV3传maskFo为alg类型的闪退BUG修复 (因为当PM的GL失败时,就会递归到的alg就是MC中的C,它的父节点还是Alg);
 */
-(void) convert2Out_Hav:(TOAlgModel*)outModel {
    //1. 数据准备 (空白无需行为化);
    if (!outModel.content_p) {
        outModel.status = TOModelStatus_Finish;
        [self.delegate toAction_SubModelFinish:outModel];
        return;
    }
    
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    //1. 第0级: 本身即是cHav节点,不用行为化,即成功 (但不用递归,等外循环返回行为结果);
    if ([TOUtils isHNGL_toModel:outModel]) {
        outModel.status = TOModelStatus_ActYes;//只需要等
        [self.delegate toAction_SubModelActYes:outModel];
        return;
    }else if (outModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        NSLog(@"\n\n=============================== 行为输出 ===============================\n%@",AlgP2FStr(outModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        outModel.status = TOModelStatus_ActYes;
        //[self.delegate toAction_SubModelActYes:outModel];
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        [self.delegate toAction_Output:@[outModel.content_p]];
        
        //2. 输出后,直接改为Finish,因为行为输出本身暂无需反省类比(但需要推动baseFo的反省类比) (所以直接代替OPushM改状态为Finish);
        //2. 2020.09.22: 注掉,因为OPushM中未排除isOut=true的情况,所以会触发反省类比,再加上这儿成了两次触发 (参考21042);
        //outModel.status = TOModelStatus_Finish;
        //[self.delegate toAction_SubModelFinish:outModel];
        return;
    }else{
        //3. 数据检查curAlg
        AIAlgNodeBase *curAlg = [SMGUtils searchNode:outModel.content_p];
        NSLog(@"\n\n=============================== 行为化_Hav ===============================\nC:%@",Alg2FStr(curAlg));
        if (!curAlg) {
            outModel.status = TOModelStatus_ActNo;
            [self.delegate toAction_SubModelFailure:outModel];
            return;
        }
        
        //3. 第2级: 优先MC匹配 (当父级为时序,且mv有效时,执行) (参考21059-344图);
        if (ISOK(outModel.baseOrGroup, TOFoModel.class)) {
            
            //a. 取出不应期
            NSArray *except_ps = TOModels2Pits([SMGUtils filterArr:outModel.subModels checkValid:^BOOL(TOModelBase *item) {
                return item.status == TOModelStatus_ActNo;
            }]);
            
            //a. 依次判断mModel,只要符合mIsC即可;
            for (NSInteger i = 0; i < theTC.inModelManager.models.count; i++) {
                AIShortMatchModel *inModel = ARR_INDEX_REVERSE(theTC.inModelManager.models, i);
                
                //b. 2020.11.27: 不应期检查 (参考2114B);
                if ([except_ps containsObject:inModel.protoAlg.pointer]) {
                    continue;
                }
                
                NSLog(@"====== checkMC ====== Proto:%@",Alg2FStr(inModel.protoAlg));
                BOOL mIsC = false;
                for (AIAlgNodeBase *item in inModel.matchAlgs) {
                    BOOL itemMIsC = [TOUtils mIsC_2:curAlg.pointer c:item.pointer] || [TOUtils mIsC_2:item.pointer c:curAlg.pointer];
                    if (!mIsC && itemMIsC) mIsC = true;
                    NSLog(@"M:%@ isC %@",Alg2FStr(item),itemMIsC ? @"true" : @"false");
                    //if (mIsC) break;
                }
                if (mIsC) {
                    NSLog(@"===> 转至PM ↓↓↓↓↓↓↓↓↓ (C作为M,P作为P)");
                    
                    //b. 生成replaceAlg转移 & 保留到outModel.replaceAlgs;
                    TOAlgModel *reModel = [TOAlgModel newWithAlg_p:inModel.protoAlg.pointer group:outModel];
                    [outModel.replaceAlgs addObject:reModel.content_p];
                    
                    //c. 将"P-M取得独特稀疏码"保留到短时记忆模型;
                    [reModel.justPValues addObjectsFromArray:[SMGUtils removeSub_ps:curAlg.content_ps parent_ps:inModel.protoAlg.content_ps]];
                        
                    //d. 将理性评价"价值分"保留到短时记忆模型;
                    //reModel.pm_Score = [AIScore score4MV:baseFo.cmvNode_p ratio:1.0f];
                    //reModel.pm_MVAT = baseFo.cmvNode_p.algsType;
                    reModel.pm_Fo = outModel.baseOrGroup.content_p;
                    reModel.pm_ProtoAlg = inModel.protoAlg;
                    reModel.pm_InModel = inModel;
                    
                    //e. 理性评价
                    __block BOOL reasonScore = true;
                    [self.delegate toAction_ReasonScorePM:reModel failure:^{
                        reasonScore = false;
                    } notNeedPM:^{
                        //f. 未跳转到PM,则将algModel设为Finish,并递归;
                        reModel.status = TOModelStatus_Finish;
                        [self.delegate toAction_SubModelFinish:reModel];
                    }];
                    
                    //g. 评价成功一条,即返回 & 评价失败时,继续循环尝试下帧短时记忆 & 所有帧都失败时,转至relativeFos;
                    if (reasonScore) return;
                }else{
                    for (AIAlgNodeBase *item in inModel.matchAlgs) NSLog(@"==> mIsC转至PM失败: %@",Alg2FStr(item));
                }
            }
        }
        
        //R-模式理性静默成功迭代: R-模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //1. 判断当前是R-模式,则进行ARS_Time评价;
        if (ISOK(outModel.baseOrGroup.baseOrGroup, ReasonDemandModel.class)) {
            ReasonDemandModel *rDemand = (ReasonDemandModel*)outModel.baseOrGroup.baseOrGroup;
            TOFoModel *dsFo = (TOFoModel*)outModel.baseOrGroup;
            BOOL arsTime = [AIScore ARS_Time:dsFo demand:rDemand];
            if (!arsTime) {
                //2. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
                NSLog(@"==> arsTime评价不急,子弹再飞一会儿");
                outModel.status = TOModelStatus_ActYes;
                [self.delegate toAction_SubModelActYes:outModel];
                return;
            }
        }
        
        //5. 去掉不应期
        NSArray *except_ps = [TOUtils convertPointersFromTOModels:outModel.actionFoModels];
        
        //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
        //AIKVPointer *baseFo_p = nil;
        //if (ISOK(outModel.baseOrGroup, TOFoModel.class)) baseFo_p = outModel.baseOrGroup.content_p;
        //if(ISOK(outModel.baseOrGroup.baseOrGroup, TOFoModel.class)) baseFo_p = outModel.baseOrGroup.baseOrGroup.content_p;
        //AIFoNodeBase *baseFo = [SMGUtils searchNode:baseFo_p];
        AIKVPointer *relativeFo_p = [AINetService getInnerV3_HN:curAlg vAT:outModel.content_p.algsType vDS:outModel.content_p.dataSource type:ATHav except_ps:except_ps];
        if (Log4ActHav) NSLog(@"getInnerAlg(有): 根据:%@ 找:%@_%@ \n联想结果:%@ %@",Alg2FStr(curAlg),outModel.content_p.algsType,outModel.content_p.dataSource,Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
        
        //6. 只要有善可尝试的方式,即从首条开始尝试;
        if (relativeFo_p) {
            TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:outModel];
            [self.delegate toAction_SubModelBegin:foModel];
            return;
        }
    }
    
    //10. 所有mModel都没成功行为化一条,则失败 (无计可施);
    outModel.status = TOModelStatus_ActNo;
    [self.delegate toAction_SubModelFailure:outModel];
}

/**
 *  MARK:--------------------对单稀疏码的变化进行行为化--------------------
 *  @desc 伪代码:
 *  1. 根据type和value_p找ATLess/ATGreater
 *      2. 找不到,failure;
 *      3. 找到,判断range是否导致条件C转移;
 *          4. 未转移: success
 *          5. 转移: C条件->递归到convert2Out_Single_Alg();
 *  _param vAT & vDS : 用作查找"大/小"的标识;
 *  _param fo : 当前maskFo场景, (所有微信息变化不应脱离场景,
 *          1. 比如鸡蛋可以通过烧成固态,但水不能,所以变成固态这种特征变化,不应脱离概念去操作);
 
 *  @version
 *      2020.12.17: getInnerAlg改为返回单条,此处调用支持,并并入流程控制fo.begin (参考21183);
 *      2020.10.18: 传递参数由baseAlg.sp_P改成pm_ProtoAlg (因为飞近上面的坚果,却飞向左) (参考2105c)
 *      2021.04.10: 传递参数由baseAlg.pm_ProtoAlg改成自取pm_InModel (因为getInnerV3要求maskFo做为联想起始) (参考22211);
 *      2021.05.17: 将不应期改为仅ActNo和ScoreNo的,因为Finish的即使用过也可以再用 (23078修复后测时发现有可行方案被不应期掉了);
 */
-(void) convert2Out_GL:(TOValueModel*)outModel {
    NSLog(@"\n\n=============================== 行为化_GL ===============================\n加工值: (%@ -> %@) ",Pit2FStr(outModel.sValue_p),Pit2FStr(outModel.content_p));
    //1. 数据准备
    AnalogyType type = [ThinkingUtils compare:outModel.sValue_p valueB_p:outModel.content_p];
    NSString *vAT = outModel.content_p.algsType;
    NSString *vDS = outModel.content_p.dataSource;
    TOAlgModel *baseAlg = (TOAlgModel*)outModel.baseOrGroup;
    
    if ((type != ATGreater && type != ATLess)) {
        WLog(@"value_行为化类参数type|value_p错误,相等不必行为化");
        //相等不必行为化,直接返回true;
        outModel.status = TOModelStatus_Finish;
        [self.delegate toAction_SubModelFinish:outModel];
        return;
    }
    
    //4. 去掉不应期
    NSArray *except_ps = [SMGUtils filterArr:outModel.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo;
    }];
    except_ps = TOModels2Pits(except_ps);
    
    //2. 根据type和value_p找ATLess/ATGreater
    //3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的概念,与新的条件概念; (2020.11.06: 由getInner1Alg直接取relativeFos);
    AIKVPointer *relativeFo_p = [AINetService getInnerV3_GL:baseAlg.pm_InModel vAT:vAT vDS:vDS type:type except_ps:except_ps];
    if (Log4ActGL) NSLog(@"getInnerAlg(%@): 根据:%@->%@ 找:%@%@ \n联想结果:%@ %@",ATType2Str(type),Pit2FStr(outModel.sValue_p),Pit2FStr(outModel.content_p),vDS,Data2FStr(type, vAT, vDS),Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
    
    //5. 转移至_fos
    if (relativeFo_p) {
        TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:outModel];
        [self.delegate toAction_SubModelBegin:foModel];
    }else{
        //6. 无计可施
        outModel.status = TOModelStatus_ActNo;
        [self.delegate toAction_SubModelFailure:outModel];
    }
}

@end
