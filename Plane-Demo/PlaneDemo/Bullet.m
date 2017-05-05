//
//  Bullet.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
+(instancetype)bulletWithPosition:(CGPoint)pos{
    Bullet *bullet = [[Bullet alloc]init];
    bullet.position = pos;
    
    return bullet;
}
@end
