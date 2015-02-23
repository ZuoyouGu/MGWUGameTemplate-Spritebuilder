//
//  Gameplay.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

const static int MOUSE_JOINT_FIX_UP_Y = 538;
const static int MOUSE_JOINT_FIX_DOWN_Y = 0;
@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_hero;
    CCNode *_test;
    CCNode *_contentNode;
    CCNode *_mouseJointNode;
    CCNode *_mouseJointFixUpNode;
    CCNode *_mouseJointFixDownNode;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_mouseFixUpJoint;
    CCPhysicsJoint *_mouseFixDownJoint;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.debugDraw = TRUE;
//    _physicsNode.collisionDelegate = self;
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_hero worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_hero boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        [_mouseJointNode setPosition:CGPointMake(touchLocation.x, _hero.position.y)];
//        [_mouseJointFixUpNode setPosition:CGPointMake(_hero.position.x, MOUSE_JOINT_FIX_UP_Y)];
//        [_mouseJointFixDownNode setPosition:CGPointMake(_hero.position.x, MOUSE_JOINT_FIX_DOWN_Y)];
        
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_hero.physicsBody anchorA:ccp(0, 0) anchorB:ccp(0, 0) restLength:0.f stiffness:30.f damping:1.0f];
//        _mouseFixUpJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:_mouseJointFixUpNode.physicsBody bodyB:_hero.physicsBody anchorA:ccp(0, 0) anchorB:ccp(0, 0) minDistance:100 maxDistance:590];
//        _mouseFixDownJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:_mouseJointFixDownNode.physicsBody bodyB:_hero.physicsBody anchorA:ccp(0, 0) anchorB:ccp(0, 0) minDistance:10 maxDistance:50];
    }
//    [self shot];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)releaseHero {
    if (_mouseJoint != nil)
    {
        // releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // when touches end, meaning the user releases their finger, release the catapult
    [self releaseHero];
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseHero];
}

- (void) update:(CCTime)delta {
    if(delta>10) {
        int x = arc4random_uniform(384);
        int force = RAND_FROM_TO(1, 3)*1000;
        [self launchEnemy:1 at:x withForce:force];
    }
}

- (void)launchEnemy {
    int x = RAND_FROM_TO(10, 370);
    int force = RAND_FROM_TO(1, 3)*1000;
    [self launchEnemy:1 at:x withForce:force];
}

- (void)launchEnemy: (int) type at: (int) x withForce: (int) force {
    // loads the Enemy.ccb we have set up in Spritebuilder
    CCNode* enemy = Nil;
    if(type==1) enemy = [CCBReader load:@"Bullet"];
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

@end
