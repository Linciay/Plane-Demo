//
//  MyPlane.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bullet.h"
@import UIKit;

@interface MyPlane : NSObject

//飞机的位置
@property (assign,nonatomic) CGPoint position;
//飞机的大小
@property (assign,nonatomic) CGSize size;
//子弹
@property (strong,nonatomic) Bullet *myBullet;



+(instancetype)heroWithSize:(CGSize)size andGameArea:(CGRect)area;
-(void)fire;

@end
