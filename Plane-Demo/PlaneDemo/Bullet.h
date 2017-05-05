//
//  Bullet.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Bullet : NSObject

//位置
@property (assign,nonatomic) CGPoint position;

+(instancetype)bulletWithPosition:(CGPoint)pos;
@end
