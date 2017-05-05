//
//  ImageResources.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "ImageResources.h"

@implementation ImageResources

+(ImageResources *)sharedImages{
    static dispatch_once_t onceToken;
    static ImageResources *shared;
    dispatch_once(&onceToken, ^{
        shared = [[ImageResources alloc]initSharedImages];
    });
    return shared;
}

-(instancetype)initSharedImages{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"images.bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithPath:bundlePath];
        
        //加载我方飞机飞行图片
        self.myPlanImages = [self imagesWithFormat:@"hero_fly_%d" withBundle:imageBundle withCount:2];
        //加载我方子弹图片
        self.myBulletImage = [self imageWithImageName:@"bullet1" withBundle:imageBundle];
        
        //加载小敌机图片
        self.smallEnemyImage = [self imageWithImageName:@"enemy1_fly_1" withBundle:imageBundle];
        self.smallBlowUpImages = [self imagesWithFormat:@"enemy1_blowup_%d" withBundle:imageBundle withCount:4];
        //加载中敌机图片
        self.middleEnemyImage = [self imageWithImageName:@"enemy2_fly_1" withBundle:imageBundle];
        self.middleBlowUpImages = [self imagesWithFormat:@"enemy2_blowup_%d" withBundle:imageBundle withCount:4];
        //加载大敌机图片
        self.bigEnemyImages = [self imagesWithFormat:@"enemy3_fly_%d" withBundle:imageBundle withCount:2];
        self.bigBlowUpImages = [self imagesWithFormat:@"enemy3_blowup_%d" withBundle:imageBundle withCount:7];
    }
    return self;
}

-(UIImage*)imageWithImageName:(NSString*)imageName withBundle:(NSBundle*)bundle{
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}

-(NSArray*)imagesWithFormat:(NSString*)format withBundle:(NSBundle*)bundle withCount:(NSInteger)count{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (int i = 1; i <= count; i++) {
        NSString *imageName = [NSString stringWithFormat:format,i];
        NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [images addObject:image];
    }
    return images;
}

@end
