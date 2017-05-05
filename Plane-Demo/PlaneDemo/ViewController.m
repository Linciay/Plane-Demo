//
//  ViewController.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/29.
//  Copyright © 2015年 Alicia. All rights reserved.
//

#import "ViewController.h"

#import "GameOnViewController.h"
#import "Enemy.h"
#import "EnemyView.h"
#import "MyPlane.h"
#import "MyPlaneView.h"
#import "Bullet.h"
#import "BulletView.h"
#import "GameModel.h"
#import "ImageResources.h"
#import "SoundTool.h"

#define SPLITESCREEN_BUTTON_ZOOMOUT 0.5

#define SBULLET_MOVE_STEP 5.0f
#define SBULLET_FIRING_INTERVAL 30

#define SMALL_ENEMY_REFRESH_STEP 150
#define MIDDLE_ENEMY_REFRESH_STEP 800
#define BIG_ENEMY_REFRESH_STEP 2500

#define SMALL_ENEMY_REFRESH_STEP_RANDOM 100
#define MIDDLE_ENEMY_REFRESH_STEP_RANDOM 200
#define BIG_ENEMY_REFRESH_STEP_RANDOM 300

static long long _steps;
static BOOL isSplitScreen;

@interface ViewController (){
    //我方飞机新位置
    CGPoint newPos;
}

@property(strong,nonatomic) CADisplayLink *gameTimer;
//游戏模型
@property (strong,nonatomic) GameModel *model;
//我方飞机视图
@property (strong,nonatomic) MyPlaneView *planeView;
//分屏上刷新我方飞机视图
@property (strong, nonatomic) MyPlaneView *secondPlaneView;
//子弹视图集合
@property (strong, nonatomic) NSMutableSet *bulletViewSet;
//敌机集合
@property (strong, nonatomic) NSMutableArray *enemyViewArray;
//分屏的第二个view
@property (strong, nonatomic) UIView *splitSecondView;
//分屏按钮
@property (strong, nonatomic) UIButton *splitScreenButton;
//合屏按钮
@property (strong, nonatomic) UIButton *mergeScreenButton;
//分屏后屏幕刷新敌机
@property (strong, nonatomic) UIImageView *splitEnemyImageView ;

@property(strong,nonnull) GameOnViewController *gameVC;
//标志分屏后敌机个数
@property (assign, nonatomic) BOOL isSplitEnemyOne;

@end

@implementation ViewController{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer  *layer;
    NSURL *url;
}
@synthesize splitScreenButton,mergeScreenButton;
@synthesize splitEnemyImageView;

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSplitScreen = NO;
    splitEnemyImageView = [[UIImageView alloc]init];
    //splitEnemyImageView.alpha = 0;


    [self.view setBackgroundColor:[UIColor clearColor]];
    
    //创建分屏按钮
//    splitScreenButton = [self createButtonWithImageName:@"SplitScreen.png"];
//    [splitScreenButton addTarget:self action:@selector(splitTheScreen) forControlEvents:UIControlEventTouchUpInside];
//    
    //创建合屏按钮
//    mergeScreenButton = [self createButtonWithImageName:@"SplitScreen_Merge.png"];
//    [mergeScreenButton addTarget:self action:@selector(mergeTheScreen) forControlEvents:UIControlEventTouchUpInside];

//    if (!isSplitScreen) {
//        [self.view addSubview:splitScreenButton];
//    }else{
//        [self.view addSubview:mergeScreenButton];
//    }
    
    [self startCamera];
    
    [self loadGame];
    
    //初始化集合
    self.bulletViewSet = [NSMutableSet set];
    self.enemyViewArray = [NSMutableArray array];
    
    //设置游戏模型
    [self setGameModel];
    
    [self startGameTimer];
    }

-(UIButton*)createButtonWithImageName:(NSString*)imageName{
    UIButton *button = [[UIButton alloc]init];
    UIImage *image = [UIImage imageNamed:imageName];
    CGFloat buttonWidth = image.size.width*SPLITESCREEN_BUTTON_ZOOMOUT;
    CGFloat buttonHeight = image.size.height*SPLITESCREEN_BUTTON_ZOOMOUT;
    button.frame = CGRectMake(self.view.frame.size.width-buttonWidth, 0, buttonWidth, buttonHeight);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    return button;
}

-(void)mergeTheScreen{
    [self.splitSecondView removeFromSuperview];
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    isSplitScreen = NO;
    [mergeScreenButton removeFromSuperview];
    [self.view addSubview:splitScreenButton];
    
}

-(void)splitTheScreen{
    self.splitSecondView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2)];
    self.splitSecondView.backgroundColor = [UIColor greenColor];
    
    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    
    [self.view insertSubview:self.splitSecondView aboveSubview:self.mergeScreenButton.imageView];
    isSplitScreen = YES;
    [splitScreenButton removeFromSuperview];
    [self.view addSubview:mergeScreenButton];
    
    //调整我方飞机位置
    CGPoint newPoint = CGPointMake([UIScreen mainScreen].bounds.size.width-self.planeView.frame.size.width/2, [UIScreen mainScreen].bounds.size.width/4+self.planeView.frame.size.height);
    self.model.myPlaneRole.position = newPoint;
    
    //分屏屏幕上添加我方飞机
    if (self.secondPlaneView) {
        [self.secondPlaneView removeFromSuperview];
        self.secondPlaneView = nil;
    }
    MyPlaneView *newPlaneView = [[MyPlaneView alloc]initWithMyPlaneImage:[ImageResources sharedImages].myPlanImages];
    newPlaneView.center = self.model.myPlaneRole.position;
    [self.splitSecondView addSubview:newPlaneView];
    
    self.secondPlaneView = newPlaneView;
    
}

-(void)loadGame{
    //self.gameVC = [[GameOnViewController alloc]init];
    [self loadResource];
    [NSThread sleepForTimeInterval:1.0f];
    //[self.view addSubview:self.gameVC.view];
}

//调用相机
-(void)startCamera{
    BOOL haveCamera = [self isCameraAvailable];
    BOOL canRearCamera = [self isRearCameraAvailable];
    if (!haveCamera) {
        //[UIAlertController alertControllerWithTitle:@"提醒" message:@"未检测到有相机设备" preferredStyle:UIAlertControllerStyleAlert];
        NSLog(@"没有相机设备");
    }
    if (!canRearCamera) {
        //[UIAlertController alertControllerWithTitle:@"提醒" message:@"后置摄像头无法使用" preferredStyle:UIAlertControllerStyleAlert];
        NSLog(@"后置摄像头故障");
    }
    
    //相机相关
    session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *devCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //NSError *error;
    AVCaptureDeviceInput *devInput = [[AVCaptureDeviceInput alloc]initWithDevice:devCamera error:nil];
    //if (!devInput) {
      //  NSLog(@"%@", [error localizedDescription]);
    //}
    [session addInput:devInput];
    
    //相机获取图像加载
    layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    layer.frame = CGRectMake(0, 0, width, height);
    //NSLog(@"width:%f,height:%f",layer.frame.size.width,layer.frame.size.height);
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:layer atIndex:0];
    [session startRunning];
    
//    //初始化的保存的文件名(保存系统临时目录)
//    NSString *path=[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"tmp.mov"];
//    //file://${path}
//    url=[NSURL fileURLWithPath:path];
//    NSLog(@"录制初始化准备完毕!");

}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/****原GameOnViewController*****/
-(void)setGameModel{
    CGSize myPlaneSize = [[ImageResources sharedImages].myPlanImages[0] size];
    
    //游戏模型
    if (self.model) {
        self.model = nil;
    }
    self.model = [GameModel gameModelWithGameArea:self.view.bounds withHeroSize:myPlaneSize];
    
    //我方飞机视图
    if (self.planeView) {
        [self.planeView removeFromSuperview];
        self.planeView = nil;
    }
    MyPlaneView *newPlaneView = [[MyPlaneView alloc]initWithMyPlaneImage:[ImageResources sharedImages].myPlanImages];
    newPlaneView.center = self.model.myPlaneRole.position;
    [self.view addSubview:newPlaneView];

    self.planeView = newPlaneView;
}

-(void)startGameTimer{
    self.gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(processing)];
    [self.gameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [[SoundTool sharedSoundTool] playMusic];
}

-(void)processing{
    _steps++;
    //我方飞机位置刷新
    self.planeView.center = self.model.myPlaneRole.position;
    self.secondPlaneView.center = self.model.myPlaneRole.position;
    
    //我方飞机射击
    if (_steps%SBULLET_FIRING_INTERVAL == 0) {
        [self.model.myPlaneRole fire];
    }
    
    //射击子弹处理
    [self checkBullets];
    
    //敌机初始化
    [self initialEnemy];
    
    //敌机位置刷新
    [self updateEnemiesPosition];
    
    //碰撞检测
    [self collisionDetection];
}

-(void)collisionDetection{
    //检测子弹与敌机碰撞，移除子弹
    NSMutableSet *removeBulletSet = [NSMutableSet set];
    
    for (BulletView *bulletView in self.bulletViewSet)
    {
        //Bullet *bullet = bulletView.planeBullet;
        
        for (EnemyView *enemyView in self.enemyViewArray)
        {
            Enemy *enemy = enemyView.enemy;
            
            if (CGRectIntersectsRect(bulletView.frame, enemyView.frame) && !enemy.isBlowUp)
            {
                enemy.hp -= 1;
                
                if (enemy.hp <= 0)
                {
                    enemy.isBlowUp = YES;
                }
                else
                {
                    if (enemy.type == showEnemyTypeBig)
                    {
                        [enemyView stopAnimating];
                    }
                    //enemyView.image = enemyView.hitImage;
                }
                [removeBulletSet addObject:bulletView];
            }
        }
    }
    
    for (BulletView *bulletView in removeBulletSet)
    {
        [bulletView removeFromSuperview];
        [self.bulletViewSet removeObject:bulletView];
    }
    
    //爆炸效果处理
    if (_steps % 4 == 0)
    {
        NSMutableSet *toRemovedSet = [NSMutableSet set];
        //NSLog(@"%ld",self.enemyViewArray.count);
        for (EnemyView *enemyView in self.enemyViewArray)
        {
            Enemy *enemy = enemyView.enemy;
            
            if (enemy.isBlowUp)
            {
                enemy.speed = 0;
                enemyView.image = enemyView.blowUpImages[enemy.blowUpFrames++];
                
            }
            
            if (enemy.blowUpFrames == enemyView.blowUpImages.count)
            {
                [toRemovedSet addObject:enemyView];
                //移除分屏上的爆炸敌机
                self.isSplitEnemyOne = NO;
                splitEnemyImageView.alpha = 0;
                [splitEnemyImageView removeFromSuperview];
            }
        }
        
        for (EnemyView *enemyView in toRemovedSet)
        {
            [self.enemyViewArray removeObject:enemyView];
            [enemyView removeFromSuperview];
        }
        [toRemovedSet removeAllObjects];
    }
    
}

-(void)initialEnemy{
    NSInteger smallTime = arc4random_uniform(SMALL_ENEMY_REFRESH_STEP_RANDOM)+SMALL_ENEMY_REFRESH_STEP;
    NSInteger middleTime = arc4random_uniform(MIDDLE_ENEMY_REFRESH_STEP_RANDOM)+MIDDLE_ENEMY_REFRESH_STEP;
    NSInteger bigTime = arc4random_uniform(BIG_ENEMY_REFRESH_STEP_RANDOM)+BIG_ENEMY_REFRESH_STEP;
    
    Enemy *enemy = nil;
    if (_steps%smallTime == 0) {
        enemy = [self.model creatEnemyWithType:showEnemyTypeSmall withSize:[ImageResources sharedImages].smallEnemyImage.size];

        [self initialEnemyWithEnemy:enemy];
    }
    if (_steps%middleTime == 0) {
        enemy = [self.model creatEnemyWithType:showEnemyTypeMiddle withSize:[ImageResources sharedImages].middleEnemyImage.size];

        [self initialEnemyWithEnemy:enemy];    }
    if (_steps%bigTime == 0) {
        //分屏不刷boss
        if (!isSplitScreen) {
            enemy = [self.model creatEnemyWithType:showEnemyTypeBig withSize:[[ImageResources sharedImages].bigEnemyImages[0] size]];
            
            [self initialEnemyWithEnemy:enemy];
            [[SoundTool sharedSoundTool]playSoundWithType:ResourceSoundTypeBigFly];
        }
    }
}

-(void)initialEnemyWithEnemy:(Enemy*)enemy{
    if (isSplitScreen) {
        if (!self.isSplitEnemyOne) {
            EnemyView *enemyView = [[EnemyView alloc]initWithEnemy:enemy];
            [self.view addSubview:enemyView];
            [self.enemyViewArray addObject:enemyView];
            self.isSplitEnemyOne = YES;
        }
    }else{
        EnemyView *enemyView = [[EnemyView alloc]initWithEnemy:enemy];
        [self.view addSubview:enemyView];
        [self.enemyViewArray addObject:enemyView];
        self.isSplitEnemyOne = YES;
    }

    
}

-(void)updateEnemiesPosition{
    
    NSMutableSet *removeEnemySet = [NSMutableSet set];

    for (EnemyView *enemyView in self.enemyViewArray) {
        Enemy *enemy = enemyView.enemy;

        enemy.position = CGPointMake(enemy.position.x, enemy.position.y+enemy.speed);
        enemyView.center = enemy.position;
        
        if (isSplitScreen) {
            //分屏时显示飞机位置
            
            splitEnemyImageView.image = enemyView.image;
            splitEnemyImageView.frame = CGRectMake(enemyView.center.x-enemyView.frame.size.width/2, enemyView.center.y-enemyView.frame.size.height/2, enemyView.bounds.size.width, enemyView.bounds.size.height);
            if (splitEnemyImageView.frame.origin.y >= enemyView.frame.size.height/3) {
                splitEnemyImageView.alpha = 1;
            }
            NSLog(@"x:%f,y:%f",splitEnemyImageView.frame.origin.x,splitEnemyImageView.frame.origin.y);
            
            [self.splitSecondView addSubview:splitEnemyImageView];
            
        }

        
        if (isSplitScreen) {
            if (CGRectGetMinY(enemyView.frame) > (self.view.bounds.size.height-enemyView.frame.size.height/2)) {
                [removeEnemySet addObject:enemyView];
                self.isSplitEnemyOne = NO;
                [splitEnemyImageView removeFromSuperview];
                splitEnemyImageView.alpha = 0;
            }
        }else{
            if (CGRectGetMinY(enemyView.frame) > self.view.bounds.size.height) {
                [removeEnemySet addObject:enemyView];
            }
        }
 

    }
    for (EnemyView *enemyView in removeEnemySet)
    {
        [self.enemyViewArray removeObject:enemyView];
        [enemyView removeFromSuperview];
    }
    [removeEnemySet removeAllObjects];
}

-(void)checkBullets{
    NSMutableSet *removeBulletSet = [NSMutableSet set];
    
    //NSLog(@"子弹集合数量:%lu", self.bulletViewSet.count);
    
    for (BulletView *bulletView in self.bulletViewSet)
    {
        CGPoint center = CGPointMake(bulletView.center.x - SBULLET_MOVE_STEP, bulletView.center.y);
        bulletView.center = center;
        
        if (CGRectGetMaxX(bulletView.frame) <= 0)
        {
            [removeBulletSet addObject:bulletView];
        }
    }
    
    for (BulletView *bulletView in removeBulletSet)
    {
        [self.bulletViewSet removeObject:bulletView];
        [bulletView removeFromSuperview];
    }
    [removeBulletSet removeAllObjects];
    
    if (self.model.myPlaneRole.myBullet)
    {
        Bullet *bullet = self.model.myPlaneRole.myBullet;
        Bullet *splitBullet = self.model.myPlaneRole.myBullet;
        
        UIImage *bulletImage = nil;
        bulletImage = [ImageResources sharedImages].myBulletImage;
        
        BulletView *bulletView =[[BulletView alloc]initWithImage:bulletImage andBullet:bullet];
        BulletView *splitBulletView = [[BulletView alloc]initWithImage:bulletImage andBullet:splitBullet];

        bulletView.center = bullet.position;
        bulletView.alpha = 0.6;
        
        splitBulletView.center = bullet.position;
        bulletView.alpha = 0.6;
        
        [self.view addSubview:bulletView];
        [self.bulletViewSet addObject:bulletView];
        
        //分屏子弹添加
        if (isSplitScreen) {
            [self.splitSecondView addSubview:splitBulletView];
            [self.bulletViewSet addObject:splitBulletView];
        }
        
        [[SoundTool sharedSoundTool] playSoundWithType:ResourceSoundTypeBullet];
        
        self.model.myPlaneRole.myBullet = nil;
    }
}

-(void)loadResource{
    [ImageResources sharedImages];
    [SoundTool sharedSoundTool];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *newTouch = [touches anyObject];
    
    CGPoint newLocation = [newTouch locationInView:self.view];
    //    CGPoint previousLocation = [newTouch preciseLocationInView:self.view];
    
    //    NSLog(@"%@",NSStringFromCGPoint(newLocation));
    //    NSLog(@"%@",NSStringFromCGPoint(previousLocation));
    
    CGFloat myPlaneWidth = self.model.myPlaneRole.size.width;
    CGFloat myPlaneHeight = self.model.myPlaneRole.size.height;
    CGFloat gameAreaWidth = self.view.bounds.size.width;
    CGFloat gameAreaHeight = self.view.bounds.size.height;
    
    if (newLocation.x+myPlaneWidth/2 > gameAreaWidth) {
        newPos.x = gameAreaWidth-myPlaneWidth/2;
    }else if (newLocation.x-myPlaneWidth/2 < 0){
        newPos.x = 0+myPlaneWidth/2;
    }else{
        newPos.x = newLocation.x;
    }
    if (newLocation.y+myPlaneHeight/2 > gameAreaHeight) {
        newPos.y = gameAreaHeight-myPlaneHeight/2;
    }else if (newLocation.y-myPlaneHeight/2 < 0){
        newPos.y = 0+myPlaneHeight/2;
    }else{
        newPos.y = newLocation.y;
    }
    
    self.model.myPlaneRole.position = newPos;
}


@end
