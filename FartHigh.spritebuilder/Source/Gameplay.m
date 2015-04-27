//
//  Gameplay.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Gameover.h"
#import "Enemy1.h"
#import "Bullet.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

#define INTERVAL_LO 40
#define INTERVAL_HI 80

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_contentNode;
    
    CGPoint _lastPosition;
    CCNode *_hero;
    BOOL _moving;
    CGFloat _speedHero;
    
    int _interval;
    int _counter;
    
    CCNode *_background1;
    CCNode *_background2;
    NSArray *_backgrounds;
    int _backgroundHeight;
    CGFloat _speedBackground;
    
    CCLabelTTF *_scoreLabel;
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
    
    // hero moving parameters
    _speedHero = 0.0f;
    _moving = false;
    
    // enemy launching parameters
    _interval = 50;
    _counter = 0;
    
    // set the background parameters
    _backgrounds = @[_background1, _background2];
    _backgroundHeight = _background1.contentSize.height*_background1.scaleY;
    _speedBackground = 100.0f;
    
    // score parameters
    _score = 0;
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)update:(CCTime)delta {
    if(_moving) {
        [self moveHero:delta];
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
        [self launchAEnemy];
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

- (void)launchAEnemy {
    int x = RAND_FROM_TO(10, 370);
    int force = RAND_FROM_TO(1, 3)*1000;
    [self launchEnemy:1 at:x withForce:force];
}

- (void)launchEnemy: (int) type at: (int) x withForce: (int) force {
    // loads the Enemy.ccb we have set up in Spritebuilder
    CCNode* enemy = Nil;
    if(type==1) enemy = [CCBReader load:@"Enemy1"];
    // position the enemy at the top
    enemy.position = ccp(x, 600);
    [_physicsNode addChild:enemy];
    
    // manually create & apply a force to launch the enemy
    CGPoint launchDirection = ccp(0, -1);
    CGPoint forceCGPoint = ccpMult(launchDirection, force);
    [enemy.physicsBody applyForce:forceCGPoint];
}

- (void)shot:(CGPoint) touchLocation {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    bullet.position = ccpAdd(_hero.position, ccp(0, 10));
    [_physicsNode addChild:bullet];
    
    // manually create & apply a force to launch the bullet
    double deltaX = touchLocation.x-_hero.position.x;
    double deltaY = touchLocation.y-_hero.position.y;
    double dividend = sqrt(deltaX*deltaX+deltaY*deltaY);
    CGPoint launchDirection = ccp(deltaX/dividend, deltaY/dividend);
    
    CCLOG(@"location: %lf, %lf", launchDirection.x, launchDirection.y);
    CGPoint force = ccpMult(launchDirection, 1000);
    [bullet.physicsBody applyForce:force];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair enemy1:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    CCLOG(@"content id: %@, %f", nodeB.class, nodeB.contentSize.height);
    
    // the bullet hits the enemy1
    if(nodeB.class == Bullet.class) {
        [self removeEnemy:nodeB];
        [self removeBullet:nodeA];
        [self updateScoreBy:2];
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

- (void)updateScoreBy:(int)score{
    _score += score;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
}

- (void)gameOver {
    // remove the hero first
    [self heroDie];
    // load the game over scene
    Gameover *overScene = (Gameover *)[CCBReader load: @"Gameover"];
    [overScene setScore:_score];
    CCScene *scene = [CCScene node];
    [scene addChild: overScene];
    [[CCDirector sharedDirector] replaceScene: scene withTransition: [CCTransition transitionCrossFadeWithDuration: 0.5]];
}

- (void)heroDie {
    [_hero removeFromParent];
}

@end
