//
//  MyPlane.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "MyPlane.h"
@import UIKit;
//子弹坐标偏移
#define BULLET_XOFFSET 10
#define BULLET_YOFFSET 1

@implementation MyPlane

+(instancetype)heroWithSize:(CGSize)size andGameArea:(CGRect)area{
    MyPlane *myPlaneRole = [[MyPlane alloc]init];
    CGFloat x = CGRectGetMaxX(area)-size.width/2;
    CGFloat y = CGRectGetMidY(area);
    myPlaneRole.position = CGPointMake(x, y);
    
    myPlaneRole.size = size;
    //NSLog(@"myPlanePosition:%@",NSStringFromCGPoint(myPlaneRole.position));
    
    return myPlaneRole;
}

-(void)fire{
    CGFloat x = self.position.x-self.size.width/2-BULLET_XOFFSET;
    CGFloat y = self.position.y-BULLET_YOFFSET;
    self.myBullet = [Bullet bulletWithPosition:CGPointMake(x, y)];
    
}

@end
