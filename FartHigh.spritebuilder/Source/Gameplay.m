//
//  Gameplay.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Enemy1.h"
#import "Bullet.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

#define INTERVAL_LO 40
#define INTERVAL_HI 80

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_hero;
    CCNode *_contentNode;
    CGPoint _lastPosition;
    CGFloat _speed;
    CCLabelTTF *_scoreLabel;
    int _interval;
    int _counter;
    BOOL _moving;
    int _score;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_hero worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    _speed = 0.0f;
    _interval = 20;
    _counter = 0;
    _moving = false;
    _score = 0;
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _speed, _hero.position.y);
    _counter++;
    if(_counter>=_interval) {
        [self launchEnemy];
        _counter = 0;
        _interval = RAND_FROM_TO(INTERVAL_LO, INTERVAL_HI);
    }
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_hero boundingBox], touchLocation))
    {
        _moving = true;
        _lastPosition = touchLocation;
    }
    else {
        [self shot];
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if(_moving) {
        // whenever touches move, update the position of the mouseJointNode to the touch position
        CGPoint curLocation = [touch locationInNode:_contentNode];
        if(curLocation.x>_lastPosition.x) {
            _speed = 100.0f;
        }
        else if(curLocation.x<_lastPosition.x) {
            _speed = -100.0f;
        }
        else {
            _speed = 0.0f;
        }
        _lastPosition = curLocation;
    }
}

- (void)stopMoving {
    _speed = 0.0f;
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
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(0, -1);
    CGPoint forceCGPoint = ccpMult(launchDirection, force);
    [enemy.physicsBody applyForce:forceCGPoint];
}

- (void)shot {
    CCNode* bullet = [CCBReader load:@"Bullet"];
    bullet.position = ccpAdd(_hero.position, ccp(0, 10));
    [_physicsNode addChild:bullet];
    
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(0, 1);
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
    [self heroDie];
    
    //    CCScene *gameOverScene = [CCBReader loadAsScene:@"GameOver"];
    //    [[CCDirector sharedDirector] replaceScene:gameOverScene];
    
}

- (void)heroDie {
    [_hero removeFromParent];
}

@end
