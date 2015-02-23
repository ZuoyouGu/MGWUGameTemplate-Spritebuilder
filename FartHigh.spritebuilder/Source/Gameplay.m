//
//  Gameplay.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCSprite *_hero;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
//    _physicsNode.collisionDelegate = self;
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self launchEnemy];
}

- (void)launchEnemy {
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode* enemy = [CCBReader load:@"Enemy1"];
    // position the penguin at the bowl of the catapult
    enemy.position = ccp(160, 200);
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:enemy];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(0, -1);
    CGPoint force = ccpMult(launchDirection, 1000);
    [enemy.physicsBody applyForce:force];
}

@end
