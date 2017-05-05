//
//  BulletView.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "BulletView.h"

@implementation BulletView

-(instancetype)initWithImage:(UIImage *)image andBullet:(Bullet *)bullet{
    self = [super initWithImage:image];
    if (self) {
        self.planeBullet = bullet;
    }

    return self;
}
//-(instancetype)initWithImage:(UIImage *)image{
//    self = [super initWithImage:image];
//
//    return self;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
