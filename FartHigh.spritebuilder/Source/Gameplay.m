//
//  Gameplay.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Gameover.h"
#import "Enemy.h"
#import "Powerup.h"
#import "Hero.h"
#import "Ice.h"
#import "Fire.h"
#import "Lightning.h"
#import "Bullet.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define RAND_FROM_TO(min, max) ((min) + arc4random_uniform((max) - (min) + 1))

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    
    CGPoint _lastPosition;
    Hero *_hero;
    BOOL _moving;
    CGFloat _speedHero;
    CCSprite *_heartIcon;
    CCLabelTTF *_heartLabel;
    
    // enemy
    NSArray *_enemyName;
    
    // powerup
    NSArray *_powerupName;
    
    // bullet
    CCSprite *_bulletIcon;
    CCLabelTTF *_bulletLabel;
    
    CCNode *_background1;
    CCNode *_background2;
    NSArray *_backgrounds;
    int _backgroundHeight;
    CGFloat _speedBackground;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_scoreLabel0;
    CCLabelTTF *_scoreLabel1;
    CCLabelTTF *_scoreLabel2;
    NSArray *_scoreLabels;
    NSInteger _scored[ENEMY_TYPES];
    int _score;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    _physicsNode.collisionDelegate = self;
    self.position = ccp(0, 0);
    
    // Load the hero
    _hero = (Hero *)[CCBReader load:@"Hero"];
    _hero.position = ccp(189, 97);
    [_physicsNode addChild:_hero];
    _speedHero = 0.0f;
    _moving = false;
    [self updateHeartLabel];
    [self updateBulletNumLabel];
    
//    _physicsNode.debugDraw = TRUE;
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_hero worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    
    
    // enemy launching parameters
    _enemyName = [NSArray arrayWithObjects: @"Ice", @"Fire", @"Lightning", nil];
    
    // powerup
    _powerupName = [NSArray arrayWithObjects: @"Health", @"Shield", @"Heart", nil];
    
    // set the background parameters
    _backgrounds = @[_background1, _background2];
    _backgroundHeight = _background1.contentSize.height*_background1.scaleY;
    _speedBackground = 100.0f;
    
    // score parameters
    for(NSInteger i=0; i<ENEMY_TYPES; i++) {
        _scored[i] = 0;
    }
    _scoreLabels = @[_scoreLabel0, _scoreLabel1, _scoreLabel2];
    _score = 0;
}

- (void)retry {
    [Enemy reset];
    [Powerup reset];
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)update:(CCTime)delta {
    if(_moving) {
        [self moveHero:delta];
    }
    
    [self rollBackground:delta];
    [self updateEnemy:delta];
    [self updatePowerup:delta];
}

- (void)moveHero:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _speedHero, _hero.position.y);
}

- (void)updateEnemy:(CCTime) delta {
    [Enemy addTimeBy:delta];
    if([Enemy timeToLaunch]) {
        [self launchEnemy];
    }
}

- (void)updatePowerup:(CCTime) delta {
    [Powerup addTimeBy:delta];
    if([Powerup timeToLaunch]) {
        [self launchPowerup];
    }
}

- (void)rollBackground:(CCTime)delta {
    for (CCNode *background in _backgrounds) {
        // move the bush
        background.position = ccp(background.position.x, background.position.y-delta * _speedBackground);
        
        // If the lower background it totally out of the scene, move it up
        if (background.position.y <= -_backgroundHeight) {
            background.position = ccp(background.position.x,
                                      background.position.y+2*_backgroundHeight);
        }
    }
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // move hero when the touch is within the boundingbox of the hero
    if (CGRectContainsPoint([_hero boundingBox], touchLocation))
    {
        _moving = true;
        _lastPosition = touchLocation;
    }
    else if([_hero hasBullet]) {
        [self shot: touchLocation];
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if(_moving) {
        // whenever touches move, update the position of the hero to the corresponding direction
        CGPoint curLocation = [touch locationInNode:_contentNode];
        if(curLocation.x>_lastPosition.x) {
            _speedHero = 100.0f;
        }
        else if(curLocation.x<_lastPosition.x) {
            _speedHero = -100.0f;
        }
        else {
            _speedHero = 0.0f;
        }
        _lastPosition = curLocation;
    }
}

- (void)stopMoving {
    _speedHero = 0.0f;
    _moving = false;
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self stopMoving];
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self stopMoving];
}

- (void)launchEnemy {
    int type = RAND_FROM_TO(0, ENEMY_TYPES-1);
    Enemy* enemy = (Enemy *)[CCBReader load:_enemyName[type]];
    
    int x = RAND_FROM_TO(0, 1)*384;
    int y = RAND_FROM_TO(50, 120)*5;
    CGPoint startPosition = ccp(x, y);
    enemy.position = startPosition;
    
    [_physicsNode addChild:enemy];
    
//    int degree = startPosition.x==0 ? RAND_FROM_TO(270, 315) : RAND_FROM_TO(180, 225);
    int deltaX = _hero.position.x-x;
    int deltaY = _hero.position.y-y;
    float radians = atan2f(deltaY, deltaX);
    
    CGPoint launchDirection = ccp(cos(radians), sin(radians));
    CGPoint forceCGPoint = ccpMult(launchDirection, [enemy getForce]*[Enemy multipleForce]);
    [enemy.physicsBody applyForce:forceCGPoint];
}

- (void)launchPowerup {
    int type = RAND_FROM_TO(0, POWERUP_TYPES-1);
//    CCLOG(@"type: %d", type);
//    int type = 1;
    Powerup* powerup = (Powerup *)[CCBReader load:_powerupName[type]];
    powerup.position = ccp(RAND_FROM_TO(10, 274), 570);
    CGPoint launchDirection = ccp(0, -1);
    CGPoint forceCGPoint = ccpMult(launchDirection, [powerup getForce]*[Powerup multipleForce]);
    [powerup.physicsBody applyForce:forceCGPoint];
    [_physicsNode addChild:powerup];
}

- (void)shot:(CGPoint) touchLocation {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    bullet.position = ccpAdd(_hero.position, ccp(0, 10));
    [_physicsNode addChild:bullet];
    
    double deltaX = touchLocation.x-bullet.position.x;
    double deltaY = touchLocation.y-bullet.position.y;
    double dividend = sqrt(deltaX*deltaX+deltaY*deltaY);
    CGPoint launchDirection = ccp(deltaX/dividend, deltaY/dividend);
    float radians = atan2f(deltaY, deltaX);
    float degree = 90-CC_RADIANS_TO_DEGREES(radians);
    bullet.rotation = degree > 0.0?degree:360.0+degree;
    
    CGPoint force = ccpMult(launchDirection, 1000);
    [bullet.physicsBody applyForce:force];
    
    [_hero shoot];
    [self updateBulletNumLabel];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(CCNode *)nodeA bullet:(CCNode *)nodeB {
    Enemy *enemy = (Enemy *)nodeA;
    [self removeBullet:nodeB];
    [enemy minusLive];
    if([enemy dead]) {
        [self removeEnemy:nodeA];
        [self updateScoreBy:[enemy getType] and:[enemy getScore]];
    }
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair powerup:(CCNode *)nodeA hero:(CCNode *)nodeB {
    Powerup *powerup = (Powerup *)nodeA;
    int type = [powerup getType];
    [self removePowerup:nodeA];
    
    if(type==0) {
        [_hero addBullet:BULLET_NUM_EVERY_TIME];
        [self updateBulletNumLabel];
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"PowerupEffect"];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = _bulletIcon.position;
        [_bulletIcon.parent addChild:explosion];
    }
    else if(type==1) {
        [_hero addShield];
    }
    else if(type==2) {
        [_hero addLives];
        [self updateHeartLabel];
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"PowerupEffect"];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = _heartIcon.position;
        [_heartIcon.parent addChild:explosion];
    }
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy:(CCNode *)nodeA hero:(CCNode *)nodeB {
    // remove the enemy
    [self removeEnemy:nodeA];
    
    // update hero's state
    Hero *hero = (Hero *)nodeB;
    if([hero hasShield]) { // ship is protected by the shield, wouldn't die
        
    }
    else if([hero hasLives]) { // this method will decrease the lives numbers automatically
        [self updateHeartLabel];
        [self liveWarning];
    }
    else {
        [self updateHeartLabel];
        [self heroDie];
    }
}

- (void)removeEnemy:(CCNode *)enemy {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"EnemyExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = enemy.position;
    [enemy.parent addChild:explosion];
    [enemy removeFromParent];
}

- (void)removePowerup:(CCNode *)powerup {
    [powerup removeFromParent];
}

- (void)removeBullet:(CCNode *)bullet {
    [bullet removeFromParent];
}

- (void)updateScoreBy:(int)type and:(int)score{
    _score += score;
    _scored[type] ++;
    CCLabelTTF *count = [_scoreLabels objectAtIndex:type];
    count.string = [NSString stringWithFormat:@"%ld", (long)_scored[type]];
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
}

- (void)updateBulletNumLabel {
    int bullets = [_hero bullets];
    _bulletLabel.string = [NSString stringWithFormat:@"%d", bullets];
    if(bullets<10) {
        _bulletLabel.color = [CCColor redColor];
    }
    else {
        _bulletLabel.color = [CCColor blackColor];
    }
}

- (void)liveWarning {
    _heartLabel.color = [CCColor redColor];
    [self scheduleOnce:@selector(changeHeartLabelToBlack) delay:0.5];
}

- (void)changeHeartLabelToBlack {
    _heartLabel.fontColor = [CCColor blackColor];
}

- (void)updateHeartLabel {
    _heartLabel.string = [NSString stringWithFormat:@"%d", [_hero lives]];
    
}

- (void)loadGameOverScene {
    // load the game over scene
    Gameover *overScene = (Gameover *)[CCBReader load: @"Gameover"];
    [overScene setScoreWithTotalScore:_score withScoreArray: _scored];
    CCScene *scene = [CCScene node];
    [scene addChild: overScene];
    [[CCDirector sharedDirector] replaceScene: scene withTransition: [CCTransition transitionCrossFadeWithDuration: 0.5]];
}

- (void)heroDie {
    // remove the hero first
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"HeroExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = _hero.position;
    [_hero.parent addChild:explosion];
    [_hero removeFromParent];
    [self scheduleOnce:@selector(loadGameOverScene) delay:1];
}
@end
