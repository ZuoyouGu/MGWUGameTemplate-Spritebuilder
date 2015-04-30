//
//  Enemy.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy {
    int _lives;
    int _force;
    int _score;
    int _type;
}

- (BOOL)dead {
    return _lives == 0;
}

- (void)minusLive {
//    CCLOG(@"lives: %d", _lives);
    _lives--;
    self.scale+=0.1;
}

// setters
- (void)withLives:(int)lives withForce:(int)force withScore:(int)score
         withType:(int)type withScale:(float)scale{
    [self setLives:lives];
    [self setForce:force];
    [self setScore:score];
    [self setType:type];
    [self setScale:scale];
    [self setCollisionType];
}

- (void)setLives:(int)lives {
    _lives = lives;
}

- (void)setForce:(int)force {
    _force = force;
}

- (void)setScore:(int)score {
    _score = score;
}

- (void)setType:(int)type {
    _type = type;
}

- (void)setCollisionType {
    self.physicsBody.collisionType = @"enemy";
}

// getters
- (int)getType {
    return _type;
}

- (int)getForce {
    return _force;
}

- (int)getScore {
    return _score;
}

@end
