//
//  ShortMatchManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "ShortMatchManager.h"

@interface ShortMatchManager ()

@property (strong, nonatomic) NSMutableArray *models;

@end

@implementation ShortMatchManager

-(NSMutableArray*)models{
    if (_models == nil) _models = [[NSMutableArray alloc] init];
    return _models;
}
-(void) add:(AIShortMatchModel*)model{
    if (model) [self.models addObject:model];
    [self checkRemoveByLimit];//新增一条时,检查有没超过有效limit条数;
}
-(AIShortMatchModel*) getFrameModel:(NSInteger)frameIndex {
    NSArray *inModels = self.models;
    return ARR_INDEX(inModels, frameIndex);
}

/**
 *  MARK:--------------------检查最大条数,切掉超过部分--------------------
 *  @desc 从后往前,保留4条有效条数 (相邻相似的计做一条) (参考32103-TODO2-方案);
 */
-(void) checkRemoveByLimit {
    //1. 一共也没四条,则不必执行;
    if (self.models.count <= cShortMemoryLimit) return;
    
    //2. 最后两条假如一样,则说明没新增有效条目,不必执行;
    if (self.models.count > 2) {
        AIShortMatchModel *aItem = ARR_INDEX_REVERSE(self.models, 0);
        AIShortMatchModel *bItem = ARR_INDEX_REVERSE(self.models, 1);
        if (![self isNewOneByRateOfAItem:aItem bItem:bItem]) return;
    }
    
    //3. 数据准备;
    NSInteger findNum = 1;//已发现条数 (默认为1条,因为初次发现不同时,其实已经是两个了);
    NSInteger minValid = 0;//最小有效的那一条下标;
    
    //4. iItem: 从后往前,倒1到1;
    if (Log4ShortLimit) NSLog(@"开始检查");
    for (NSInteger i = self.models.count - 1; i >= 1; i--) {
        
        //5. jItem: 即i的前一条;
        NSInteger j = i - 1;
        AIShortMatchModel *iItem = ARR_INDEX(self.models, i);
        AIShortMatchModel *jItem = ARR_INDEX(self.models, j);
        
        //6. 不是新的一条时,计数+1;
        BOOL isNewOne = [self isNewOneByRateOfAItem:iItem bItem:jItem];
        if (isNewOne) findNum++;
        if (isNewOne && Log4ShortLimit) NSLog(@"%ld : %ld => 发现数:%ld (%@ : %@)",i,j,findNum,Alg2FStr(iItem.protoAlg),Alg2FStr(jItem.protoAlg));
        
        //7. 超过4条时,停止循环,超过4条的部分全切掉;
        if (findNum > cShortMemoryLimit) {
            minValid = i;//i有效,j无效;
            break;
        }
    }
    if (minValid > 0 && Log4ShortLimit) NSLog(@"瞬时记忆切前: %@",CLEANSTR([SMGUtils convertArr:self.models convertBlock:^id(AIShortMatchModel *obj) { return Alg2FStr(obj.protoAlg); }]));
    
    //8. 切掉无效部分;
    if (minValid > 0) self.models = [[NSMutableArray alloc] initWithArray:ARR_SUB(self.models, minValid, self.models.count - minValid)];
    if (minValid > 0 && Log4ShortLimit) NSLog(@"瞬时记忆切后: %@",CLEANSTR([SMGUtils convertArr:self.models convertBlock:^id(AIShortMatchModel *obj) { return Alg2FStr(obj.protoAlg); }]));
}

/**
 *  MARK:--------------------是否新的一条: 根据AIShortMatchModel之间的matchAlgs的交集率计算--------------------
 *  @desc 相邻matchAlgs交集率高于30%的计为一条 (参考32103-TODO2-方案);
 */
-(BOOL) isNewOneByRateOfAItem:(AIShortMatchModel*)aItem bItem:(AIShortMatchModel*)bItem {
    //1. 计算交集率;
    NSArray *aAlgs = [SMGUtils convertArr:aItem.matchAlgs_Si convertBlock:^id (AIMatchAlgModel *obj) { return obj.matchAlg; }];
    NSArray *bAlgs = [SMGUtils convertArr:bItem.matchAlgs_Si convertBlock:^id (AIMatchAlgModel *obj) { return obj.matchAlg; }];
    NSArray *sameAlgs = [SMGUtils filterArrA:aAlgs arrB:bAlgs];
    NSInteger totalCount = MIN(aAlgs.count, bAlgs.count);
    CGFloat rate = totalCount > 0 ? (float)sameAlgs.count / totalCount : 0;
    
    //2. 交集率低于30%时,计为新的一条;
    if (Log4ShortLimit) NSLog(@"isNewOneA(%.2f): %@",rate,Alg2FStr(aItem.protoAlg));
    if (Log4ShortLimit) NSLog(@"isNewOneB(%.2f): %@",rate,Alg2FStr(bItem.protoAlg));
    return rate < 0.3f;
}

/**
 *  MARK:--------------------获取瞬时记忆序列--------------------
 *  @param isMatch
 *      true : matchAlgs返回以后逐步替代shortCache;
 *      false: protoAlgs(由algsDic生成的algNode_p)返回;
 *  @desc 存最多4条algNode_p;
 *  @version
 *      2019.01.23: 将protoAlg收集到瞬时记忆中;
 *      xxxx.xx.xx: 输入概念识别成功时,加入matchAlg;
 *      2020.06.26: 识别失败时,将protoAlg加入 (以避免,飞行行为因不被识别而无法加入的BUG);
 *      2020.08.17: 将瞬时记忆整合到短时记忆中;
 *      2020.11.13: 当isMatch=true时,Match为空时,取Part,最后再取Proto (因以往未取Part,导致最初训练时的时序识别失败) (参考21144);
 *  @result 返回AIShortMatchModel_Simple数组 notnull;
 */
-(NSMutableArray*) shortCache:(BOOL)isMatch{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIShortMatchModel *mModel in self.models) {
        //2. 逐个取: isMatch=true时,取优先级为(Match > Part > Proto) / isMatch=false时,直接取proto;
        AIKVPointer *itemAlg_p;
        if (isMatch) {
            if (mModel.firstMatchAlg) {
                itemAlg_p = mModel.firstMatchAlg.matchAlg;
            }
        }
        if (!itemAlg_p) itemAlg_p = mModel.protoAlg.pointer;
        
        //3. 有效则收集;
        if (itemAlg_p) {
            AIShortMatchModel_Simple *simple = [AIShortMatchModel_Simple newWithAlg_p:itemAlg_p inputTime:mModel.inputTime isTimestamp:true];
            [result addObject:simple];
        }
    }
    return result;
}

-(void) clear{
    [self.models removeAllObjects];
}

@end
