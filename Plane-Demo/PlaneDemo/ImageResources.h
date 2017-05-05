//
//  ImageResources.h
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ImageResources : NSObject
//我方飞机飞行图片
@property (strong, nonatomic) NSArray *myPlanImages;
//我方飞机子弹图片
@property (strong, nonatomic) UIImage *myBulletImage;

//小敌机飞行图片
@property (strong, nonatomic) UIImage *smallEnemyImage;
//小敌机爆炸图片数组
@property (strong, nonatomic) NSArray *smallBlowUpImages;
//中敌机飞行图片
@property (strong, nonatomic) UIImage *middleEnemyImage;
//中敌机爆炸图片数组
@property (strong, nonatomic) NSArray *middleBlowUpImages;
//大敌机飞行图片
@property (strong, nonatomic) NSArray *bigEnemyImages;
//大敌机爆炸图片数组
@property (strong, nonatomic) NSArray *bigBlowUpImages;

+ (ImageResources *)sharedImages;
@end
