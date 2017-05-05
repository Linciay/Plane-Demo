//
//  EnermyView.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "EnemyView.h"
#import "ImageResources.h"

@implementation EnemyView

-(instancetype)initWithEnemy:(Enemy*)inEnemy{
    self  = [super init];
    if (self) {
        
        self.enemy = inEnemy;
        
        ImageResources *res = [ImageResources sharedImages];
        
        switch (self.enemy.type) {
            case showEnemyTypeSmall:
                self.image = res.smallEnemyImage;
                self.blowUpImages = res.smallBlowUpImages;
                self.frame = CGRectMake(0, 0, self.image.size.width*1.35, self.image.size.height*1.35);
                break;
            case showEnemyTypeMiddle:
                self.image = res.middleEnemyImage;
                self.blowUpImages = res.middleBlowUpImages;
                self.frame = CGRectMake(0, 0, self.image.size.width*1.35, self.image.size.height*1.35);
                break;
            case showEnemyTypeBig:
                self.image = res.bigEnemyImages[0];
                
                self.animationImages = res.bigEnemyImages;
                self.animationDuration = 0.5f;
                [self startAnimating];
                
                self.blowUpImages = res.bigBlowUpImages;
                self.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
                break;
            default:
                break;
        }
        self.center = self.enemy.position;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
