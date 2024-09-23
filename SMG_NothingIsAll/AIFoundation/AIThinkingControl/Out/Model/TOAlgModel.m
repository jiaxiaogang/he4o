//
//  TOAlgModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOAlgModel.h"

@interface TOAlgModel()

@property (strong, nonatomic) NSMutableArray *actionFoModels;
@property (strong, nonatomic) NSMutableArray *subModels;    //旧版本用于存subValueModel;
@property (strong, nonatomic) NSMutableArray *subDemands;   //新版用于放hDemand (self是alg时,subDemands中放着一条子H任务subHDemand);

@end

@implementation TOAlgModel

+(TOAlgModel*) newWithAlg_p:(AIKVPointer*)alg_p group:(TOModelBase<ISubModelsDelegate>*)group {
    TOAlgModel *result = [[TOAlgModel alloc] initWithContent_p:alg_p];
    result.status = TOModelStatus_Runing;
    if (group) [group.subModels addObject:result];
    result.baseOrGroup = group;
    return result;
}

-(NSMutableArray *)actionFoModels{
    if (_actionFoModels == nil) _actionFoModels = [[NSMutableArray alloc] init];
    return _actionFoModels;
}

-(NSMutableArray *)subModels {
    if (_subModels == nil) _subModels = [[NSMutableArray alloc] init];
    return _subModels;
}

-(NSMutableArray*) subDemands{
    if (_subDemands == nil) _subDemands = [[NSMutableArray alloc] init];
    return _subDemands;
}

//-(NSMutableDictionary *)cGLDic{
//    if (!_cGLDic) _cGLDic = [[NSMutableDictionary alloc] init];
//    return _cGLDic;
//}
//-(NSMutableArray *)replaceAlgs{
//    if (!_replaceAlgs) _replaceAlgs = [[NSMutableArray alloc] init];
//    return _replaceAlgs;
//}
//-(NSMutableArray *)justPValues{
//    if (!_justPValues) _justPValues = [[NSMutableArray alloc] init];
//    return _justPValues;
//}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.subModels = [aDecoder decodeObjectForKey:@"subModels"];
        self.subDemands = [aDecoder decodeObjectForKey:@"subDemands"];
        self.actionFoModels = [aDecoder decodeObjectForKey:@"actionFoModels"];
        self.feedbackAlg = [aDecoder decodeObjectForKey:@"feedbackAlg"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.subModels forKey:@"subModels"];
    [aCoder encodeObject:self.subDemands forKey:@"subDemands"];
    [aCoder encodeObject:self.actionFoModels forKey:@"actionFoModels"];
    [aCoder encodeObject:self.feedbackAlg forKey:@"feedbackAlg"];
}

@end
