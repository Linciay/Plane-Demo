//
//  Enermy.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSInteger, ShowEnemyType){
    showEnemyTypeSmall = 0,
    showEnemyTypeMiddle,
    showEnemyTypeBig
};

@interface Enemy : NSObject
//位置
@property (assign,nonatomic) CGPoint position;
//速度
@property (assign,nonatomic) NSInteger speed;
//敌机生命值
@property (assign,nonatomic) NSInteger hp;
//敌机类型
@property (assign,nonatomic) ShowEnemyType type;
//爆炸标识
@property (assign,nonatomic) BOOL isBlowUp;
//爆炸帧数控制
@property (assign,nonatomic) NSInteger blowUpFrames;

+(instancetype)enemyWithType:(ShowEnemyType)enemyType withSize:(CGSize)size andGameArea:(CGRect)gameArea;

@end
