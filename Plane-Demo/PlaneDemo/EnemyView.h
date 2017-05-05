//
//  EnermyView.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enemy.h"

@interface EnemyView : UIImageView
@property (strong, nonatomic) Enemy* enemy;

@property (strong, nonatomic) NSArray *blowUpImages;

-(instancetype)initWithEnemy:(Enemy*)inEnemy;

@end
