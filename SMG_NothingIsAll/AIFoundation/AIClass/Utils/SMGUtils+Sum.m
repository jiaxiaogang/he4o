//
//  SMGUtils+Sum.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/30.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "SMGUtils+Sum.h"
#import "AINetIndex.h"
#import "AIPort.h"

@implementation SMGUtils (Sum)

/**
 *  MARK:--------------------值域求和--------------------
 *  @desc 束波求和简化版,采取线函数来替代找交点 (参考21212 & 21213);
 *  @result Array[SumModel] notnull
 */
+(NSArray*) sumSPorts:(NSArray*)sPorts pPorts:(NSArray*)pPorts{
    //1. 数据检查;
    sPorts = ARRTOOK(sPorts);
    pPorts = ARRTOOK(pPorts);
    NSArray *allPorts = [SMGUtils collectArrA:sPorts arrB:pPorts];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 从小到大排序;
    [allPorts sortedArrayUsingComparator:^NSComparisonResult(AIPort *p1, AIPort *p2) {
        double v1 = [NUMTOOK([AINetIndex getData:p1.target_p]) doubleValue];
        double v2 = [NUMTOOK([AINetIndex getData:p2.target_p]) doubleValue];
        return [SMGUtils compareFloatA:v2 floatB:v1];
    }];
    
    //3. 取上组和当前组;
    NSMutableArray *lastGroup = [[NSMutableArray alloc] init];
    NSMutableArray *curGroup = [[NSMutableArray alloc] init];
    AnalogyType curType = ATNone;
    for (AIPort *item in allPorts) {
        //4. 切换组: (收集中!=None & 非同组!=itemType);
        AnalogyType itemType = [sPorts containsObject:item] ? ATSub : ATPlus;
        if (curType != ATNone && curType != itemType) {
            //5. 切组后: curGroup与lastGroup进行对比找出各自最有竞争力的成员;
            
            //7. 切组后: 根据最有竞争力成员算出交点;
            
            //8. 生成模型,并收集;
            SumModel *model = [[SumModel alloc] init];
            model.dotValue = 0;
            model.type = curType;
            [result addObject:model];
            
            //9. 当前组变成上组 (当前组重置);
            [lastGroup removeAllObjects];
            [lastGroup addObjectsFromArray:curGroup];
            [curGroup removeAllObjects];
            
        }
        //10. 收集curGroup: (不切组 或 切完组);
        [curGroup addObject:item];
        curType = itemType;
    }
    return result;
}

/**
 *  MARK:--------------------判断value处在S还是P中--------------------
 */
+(AnalogyType) checkValueSPType:(double)value sumSPModel:(NSArray*)sumSPModel{
    //1. 数据准备;
    sumSPModel = ARRTOOK(sumSPModel);
    
    //2. 从中找value匹配;
    for (SumModel *item in sumSPModel) {
        
    }
    return ATNone;
}

@end
