//
//  GameOnViewController.m
//  PlaneDemo
//
//  Created by Alicia on 15/7/30.
//  Copyright © 2015年 Alicia. All rights reserved.
//

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

#define SBULLET_MOVE_STEP 5.0f
#define SBULLET_FIRING_INTERVAL 30

#define SMALL_ENEMY_REFRESH_STEP 150
#define MIDDLE_ENEMY_REFRESH_STEP 800
#define BIG_ENEMY_REFRESH_STEP 2500

#define SMALL_ENEMY_REFRESH_STEP_RANDOM 100
#define MIDDLE_ENEMY_REFRESH_STEP_RANDOM 200
#define BIG_ENEMY_REFRESH_STEP_RANDOM 300

static long long _steps;

@interface GameOnViewController (){
    //我方飞机新位置
    CGPoint newPos;
}

@property(strong,nonatomic) CADisplayLink *gameTimer;
//游戏模型
@property (strong,nonatomic) GameModel *model;
//我方飞机视图
@property (strong,nonatomic) MyPlaneView *planeView;
//子弹视图集合
@property (strong, nonatomic) NSMutableSet *bulletViewSet;
//敌机集合
@property (strong, nonatomic) NSMutableSet *enemyViewSet;

@end

@implementation GameOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *splitScreenButton = [[UIButton alloc]init];
    splitScreenButton.backgroundColor = [UIColor redColor];
    [splitScreenButton setBackgroundImage:[UIImage imageNamed:@"MyPlane1.png"] forState:UIControlStateHighlighted];
    splitScreenButton.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:splitScreenButton];
    
    //初始化集合
    self.bulletViewSet = [NSMutableSet set];
    self.enemyViewSet = [NSMutableSet set];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //设置游戏模型
    [self setGameModel];
    
    [self startGameTimer];
}

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
        
        for (EnemyView *enemyView in self.enemyViewSet)
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
        
        for (EnemyView *enemyView in self.enemyViewSet)
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
            }
        }
        
        for (EnemyView *enemyView in toRemovedSet)
        {
            [self.enemyViewSet removeObject:enemyView];
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
        [self initialEnemyWithEnemy:enemy];
    }
    if (_steps%bigTime == 0) {
        enemy = [self.model creatEnemyWithType:showEnemyTypeBig withSize:[[ImageResources sharedImages].bigEnemyImages[0] size]];
        [self initialEnemyWithEnemy:enemy];
        
        [[SoundTool sharedSoundTool]playSoundWithType:ResourceSoundTypeBigFly];
    }
}

-(void)initialEnemyWithEnemy:(Enemy*)enemy{
    EnemyView *enemyView = [[EnemyView alloc]initWithEnemy:enemy];
    [self.view addSubview:enemyView];
    [self.enemyViewSet addObject:enemyView];
}

-(void)updateEnemiesPosition{
    
    NSMutableSet *removeEnemySet = [NSMutableSet set];
    
    for (EnemyView *enemyView in self.enemyViewSet) {
        Enemy *enemy = enemyView.enemy;
        enemy.position = CGPointMake(enemy.position.x, enemy.position.y+enemy.speed);
        enemyView.center = enemy.position;
        
        if (CGRectGetMinY(enemyView.frame) > self.view.bounds.size.height) {
            [removeEnemySet addObject:enemyView];
        }
    }
    for (EnemyView *enemyView in removeEnemySet)
    {
        [self.enemyViewSet removeObject:enemyView];
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
        UIImage *bulletImage = nil;
        bulletImage = [ImageResources sharedImages].myBulletImage;
        
        BulletView *bulletView =[[BulletView alloc]initWithImage:bulletImage andBullet:bullet];
        //BulletView *bulletView =[[BulletView alloc]initWithImage:bulletImage];
        bulletView.center = bullet.position;
        bulletView.alpha = 0.6;
        [self.view addSubview:bulletView];
        [self.bulletViewSet addObject:bulletView];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
