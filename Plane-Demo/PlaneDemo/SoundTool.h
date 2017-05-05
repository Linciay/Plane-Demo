//
//  SoundTool.h
//  PlaneDemo
//
//  Created by Alicia on 15/8/8.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ResourceSoundType){
    ResourceSoundTypeBullet = 0,
    ResourceSoundTypeSmallBlowup,
    ResourceSoundTypeMiddleBlowup,
    ResourceSoundTypeBigFly,
    ResourceSoundTypeBigBlowup,
    ResourceSoundTypeMyPlaneBlowup
};

@interface SoundTool : NSObject

+(id)sharedSoundTool;
-(void)playSoundWithType:(ResourceSoundType)soundType;
-(void)playMusic;
@end
