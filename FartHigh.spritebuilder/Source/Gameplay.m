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
#import "Hero.h"
#import "Ice.h"
#import "Fire.h"
#import "Lightning.h"
#import "Bullet.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define RAND_FROM_TO(min, max) ((min) + arc4random_uniform((max) - (min) + 1))

#define INTERVAL_LO 20
#define INTERVAL_HI 60
#define NUM_OF_ENEMY    3
#define MAX_TIME_DIFF   5

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    
    CGPoint _lastPosition;
    Hero *_hero;
    BOOL _moving;
    CGFloat _speedHero;
    
    // enemy
    NSArray *_enemyName;
    CCTime _timeDiff;
    float _multipleForce;
    int _interval;
    int _counter;
    
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
    NSInteger _scored[NUM_OF_ENEMY];
    int _score;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
//    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_hero worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    
    // Load the hero
    _hero = (Hero *)[CCBReader load:@"Hero"];
    _hero.position = ccp(189, 97);
    [_physicsNode addChild:_hero];
    _speedHero = 0.0f;
    _moving = false;
    
    // enemy launching parameters
    _enemyName = [NSArray arrayWithObjects: @"Ice", @"Fire", @"Lightning", nil];
    _interval = 50;
    _counter = 0;
    _multipleForce = 1.0f;
    _timeDiff = 0;
    
    // set the background parameters
    _backgrounds = @[_background1, _background2];
    _backgroundHeight = _background1.contentSize.height*_background1.scaleY;
    _speedBackground = 100.0f;
    
    // score parameters
    for(NSInteger i=0; i<NUM_OF_ENEMY; i++) {
        _scored[i] = 0;
    }
    _scoreLabels = @[_scoreLabel0, _scoreLabel1, _scoreLabel2];
    _score = 0;
}

- (void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)update:(CCTime)delta {
    if(_moving) {
        [self moveHero:delta];
    }
    
    _timeDiff += delta;
    if(_timeDiff>MAX_TIME_DIFF) {
        _multipleForce += 0.1;
        _timeDiff = 0;
    }
    
    [self rollBackground:delta];
    [self updateEnemy];
}

- (void)moveHero:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _speedHero, _hero.position.y);
}

- (void)updateEnemy {
    _counter++;
    if(_counter>=_interval) {
        [self launchAnEnemy];
        _counter = 0;
        _interval = RAND_FROM_TO(INTERVAL_LO, INTERVAL_HI);
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
    else {
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

- (void)launchAnEnemy {
    int x = RAND_FROM_TO(0, 1)*384;
    int y = RAND_FROM_TO(50, 120)*5;
    CGPoint startPosition = ccp(x, y);
    int type = RAND_FROM_TO(0, 2);
//    int type = 0;
    [self launchEnemy:type at:startPosition];
}

- (void)launchEnemy: (int) type at: (CGPoint) startPosition{
    Enemy* enemy = (Enemy *)[CCBReader load:_enemyName[type]];
    enemy.position = startPosition;
    [_physicsNode addChild:enemy];
    
    // manually create & apply a force to launch the enemy
    int degree = startPosition.x==0 ? RAND_FROM_TO(270, 315) : RAND_FROM_TO(180, 225);
    float radians = CC_DEGREES_TO_RADIANS(degree);
    
    CGPoint launchDirection = ccp(cos(radians), sin(radians));
//    CCLOG(@"degree is: %d, (%lf, %lf)", degree, launchDirection.x, launchDirection.y);
    CGPoint forceCGPoint = ccpMult(launchDirection, [enemy getForce]*_multipleForce);
    [enemy.physicsBody applyForce:forceCGPoint];
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
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ice:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    // the bullet hits the Ice
    if(nodeB.class == Bullet.class) {
        Enemy *enemy = (Enemy *)nodeA;
        [self removeBullet:nodeB];
        [enemy minusLive];
        if([enemy dead]) {
            [self removeEnemy:nodeA];
            [self updateScoreByType:0 and:[enemy getScore]];
        }
    }
    else if(nodeB.class == CCSprite.class) {
        [self gameOver];
    }
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair fire:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    // the bullet hits the Fire
    if(nodeB.class == Bullet.class) {
        Enemy *enemy = (Enemy *)nodeA;
        [self removeBullet:nodeB];
        [enemy minusLive];
        if([enemy dead]) {
            [self removeEnemy:nodeA];
            [self updateScoreByType:1 and:[enemy getScore]];
        }
    }
    else if(nodeB.class == CCSprite.class) {
        [self gameOver];
    }
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair lightning:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    // the bullet hits the Lightning
    if(nodeB.class == Bullet.class) {
        Lightning *enemy = (Lightning *)nodeA;
        [self removeBullet:nodeB];
        [enemy minusLive];
        if([enemy dead]) {
            [self removeEnemy:nodeA];
            [self updateScoreByType:2 and:[enemy getScore]];
        }
    }
    else if(nodeB.class == CCSprite.class) {
        [self gameOver];
    }
}

- (void)removeEnemy:(CCNode *)enemy {
    [enemy removeFromParent];
}

- (void)removeBullet:(CCNode *)bullet {
    [bullet removeFromParent];
}

- (void)updateScoreByType:(int)type and:(int)score{
    _score += score;
    _scored[type] ++;
    CCLabelTTF *count = [_scoreLabels objectAtIndex:type];
    count.string = [NSString stringWithFormat:@"%ld", (long)_scored[type]];
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
}

- (void)gameOver {
    // remove the hero first
    [self heroDie];
    
    // load the game over scene
    Gameover *overScene = (Gameover *)[CCBReader load: @"Gameover"];
    [overScene setScoreWithTotalScore:_score withScoreArray: _scored];
    CCScene *scene = [CCScene node];
    [scene addChild: overScene];
    [[CCDirector sharedDirector] replaceScene: scene withTransition: [CCTransition transitionCrossFadeWithDuration: 0.5]];
}

- (void)heroDie {
    [_hero removeFromParent];
}

@end
