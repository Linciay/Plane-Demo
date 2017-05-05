//
//  SoundTool.m
//  PlaneDemo
//
//  Created by Alicia on 15/8/8.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "SoundTool.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundTool ()
@property (strong,nonatomic) AVAudioPlayer *musicPlayer;
@property (strong,nonatomic) NSDictionary *soundDict;
@end

@implementation SoundTool

+(id)sharedSoundTool{
    static dispatch_once_t onceToken;
    static SoundTool *sharedTool;
    dispatch_once(&onceToken, ^{
        sharedTool = [[SoundTool alloc]initSharedTool];
    });
    return sharedTool;
}

-(id)initSharedTool{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"music.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        
        NSString *filePath = [bundle pathForResource:@"game_music" ofType:@"mp3"];
        NSURL *urlBgm = [NSURL fileURLWithPath:filePath];
        
        [self loadSoundDictWithBundle:bundle];
        
        NSError *error;
        self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:urlBgm error:&error];
        if (error) {
            NSLog(@"初始化音乐播放器失败，错误:%@",error);
        }
        
        self.musicPlayer.numberOfLoops = -1;
        [self.musicPlayer prepareToPlay];
        
    }
    return self;
}

-(void)loadSoundDictWithBundle:(NSBundle*)bundle{
    NSMutableDictionary *dictSoundEffect = [NSMutableDictionary dictionary];
    NSArray *soundsArray = @[@"bullet",
                       @"enemy1_down",
                       @"enemy2_down",
                       @"enemy3_down",
                       @"enemy3_out",
                       @"game_over"
                       ];
    for (NSString *soundName in soundsArray) {
        SystemSoundID soundID = [self soundIDWithName:soundName withBundle:bundle];
        [dictSoundEffect setObject:@(soundID) forKey:soundName];
    }
    self.soundDict = dictSoundEffect;
}

-(SystemSoundID)soundIDWithName:(NSString*)name withBundle:(NSBundle*)bundle{
    SystemSoundID soundID;
    NSString *soundPath = [bundle pathForResource:name ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:soundPath];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    return soundID;
}

-(void)playSoundWithType:(ResourceSoundType)soundType{
    NSString *soundName = nil;
    switch (soundType) {
        case ResourceSoundTypeBullet:
            soundName = @"bullet";
            break;
        case ResourceSoundTypeSmallBlowup:
            soundName = @"enemy1_down";
            break;
        case ResourceSoundTypeMiddleBlowup:
            soundName = @"enemy2_down";
            break;
        case ResourceSoundTypeBigFly:
            soundName = @"enemy3_out";
            break;
        case ResourceSoundTypeBigBlowup:
            soundName = @"enemy3_down";
            break;
        case ResourceSoundTypeMyPlaneBlowup:
            soundName = @"game_over";
            break;
        default:
            break;
    }
    [self playSoundWithSoundName:soundName];
}

-(void)playSoundWithSoundName:(NSString*)soundName{
    SystemSoundID soundId = [self.soundDict[soundName] unsignedIntValue];
    AudioServicesPlaySystemSound(soundId);
}

-(void)playMusic{
    [self.musicPlayer play];
}

@end
