//
//  GameModel.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel

+(instancetype)gameModelWithGameArea:(CGRect)myGameArea withHeroSize:(CGSize)size{
    GameModel *model = [[GameModel alloc]init];
    model.gameArea = myGameArea;
    model.myPlaneRole = [MyPlane heroWithSize:size andGameArea:myGameArea];
    
    return model;
}

-(Enemy *)creatEnemyWithType:(ShowEnemyType)type withSize:(CGSize)size{
    Enemy *enemy = [Enemy enemyWithType:type withSize:size andGameArea:self.gameArea];
    
    return enemy;
}
@end
