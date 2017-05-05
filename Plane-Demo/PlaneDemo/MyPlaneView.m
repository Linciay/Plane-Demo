//
//  MyPlaneView.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/31.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "MyPlaneView.h"

@implementation MyPlaneView

-(instancetype)initWithMyPlaneImage:(NSArray *)images{
    self = [super initWithImage:images[0]];
    if (self) {
        self.animationImages = images;
        self.animationDuration = 1.0f;
        [self startAnimating];
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
