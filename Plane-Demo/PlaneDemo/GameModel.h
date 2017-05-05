//
//  GameModel.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "MyPlane.h"
#import "Enemy.h"

@interface GameModel : NSObject

//游戏区域
@property (assign,nonatomic) CGRect gameArea;
//我方飞机模型
@property (strong,nonatomic) MyPlane *myPlaneRole;

+(instancetype)gameModelWithGameArea:(CGRect)myGameArea withHeroSize:(CGSize)size;

-(Enemy*)creatEnemyWithType:(ShowEnemyType)type withSize:(CGSize)size;
@end
