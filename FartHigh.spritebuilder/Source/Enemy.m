//
//  Enemy.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"
#define RAND_FROM_TO(min, max) ((min) + arc4random_uniform((max) - (min) + 1))
#define MAX_TIME_DIFF   2
#define INTERVAL_LO 20
#define INTERVAL_HI 60
#define DELTA_FORCE     0.1

@implementation Enemy {
    int _lives;
    int _force;
    int _score;
    int _type;
    
}

static int _interval = 50;
static int _counter = 0;
static float _multipleForce = 1.0f;
static CCTime _timeDiff = 0;

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
    self.physicsBody.collisionCategories = @[@"enemy"];
    self.physicsBody.collisionMask = @[@"hero", @"bullet"];
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

// static variables
+ (float)multipleForce {
    return _multipleForce;
}

+ (void)increaseForce {
    _multipleForce+=DELTA_FORCE;
}

+ (void)addTimeBy:(CCTime)delta {
    _timeDiff += delta;
    if(_timeDiff > MAX_TIME_DIFF) {
        [self increaseForce];
        _timeDiff = 0.0;
    }
}

+ (BOOL)timeToLaunch {
    _counter++;
    if(_counter>=_interval) {
        _counter = 0;
        _interval = RAND_FROM_TO(INTERVAL_LO, INTERVAL_HI);
        return true;
    }
    else {
        return false;
    }
}

+ (void)reset {
    _interval = RAND_FROM_TO(INTERVAL_LO, INTERVAL_HI);
    _counter = 0;
    _multipleForce = 1.0f;
    _timeDiff = 0;
}
@end
