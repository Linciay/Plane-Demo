//
//  BulletView.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bullet.h"

@interface BulletView : UIImageView

@property (strong,nonatomic) Bullet *planeBullet;

-(id)initWithImage:(UIImage *)image andBullet:(Bullet*)bullet;
//-(id)initWithImage:(UIImage *)image;
@end
