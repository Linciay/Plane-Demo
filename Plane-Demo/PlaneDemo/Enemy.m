//
//  Enermy.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "Enemy.h"
#import "SoundTool.h"

@implementation Enemy
+(instancetype)enemyWithType:(ShowEnemyType)enemyType withSize:(CGSize)size andGameArea:(CGRect)gameArea{
    Enemy *enemy = [[Enemy alloc]init];
    
    enemy.type = enemyType;
    
    CGFloat x = arc4random_uniform(gameArea.size.width*2/3-size.width)+size.width/2;
    CGFloat y = -size.height;
    enemy.position = CGPointMake(x, y);
    
    switch (enemyType) {
        case showEnemyTypeSmall:
            enemy.speed = arc4random_uniform(3)+2;
            enemy.hp = 1;
            break;
        case showEnemyTypeMiddle:
            enemy.speed = arc4random_uniform(2)+2;
            enemy.hp = 3;
            break;
        case showEnemyTypeBig:
            enemy.speed = arc4random_uniform(1)+2;
            enemy.hp = 5;
        default:
            break;
    }
    
    enemy.isBlowUp = NO;
    enemy.blowUpFrames = 0;
    
    return enemy;
}

-(void)setIsBlowUp:(BOOL)isBlowUp{
    if (isBlowUp == NO) {
        _isBlowUp = NO;
    }else{
        _isBlowUp = YES;
        ResourceSoundType soundType;
        switch (self.type) {
            case showEnemyTypeSmall:
                soundType = ResourceSoundTypeSmallBlowup;
                break;
            case showEnemyTypeMiddle:
                soundType = ResourceSoundTypeMiddleBlowup;
                break;
            case showEnemyTypeBig:
                soundType = ResourceSoundTypeBigBlowup;
                break;
            default:
                break;
        }
        [[SoundTool sharedSoundTool] playSoundWithType:soundType];
    }
    
}

@end
