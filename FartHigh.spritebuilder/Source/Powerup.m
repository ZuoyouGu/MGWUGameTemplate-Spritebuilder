//
//  Powerup.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Powerup.h"
#import "hero.h"
#define RAND_FROM_TO(min, max) ((min) + arc4random_uniform((max) - (min) + 1))
#define MAX_TIME_DIFF   2
#define INTERVAL_LO 200
#define INTERVAL_HI 600
#define DELTA_FORCE     0.1

@implementation Powerup {
    int _type;
    int _force;
}

static int _interval = 500;
static int _counter = 0;
static float _multipleForce = 1.0f;
static CCTime _timeDiff = 0;

- (void)withType:(int)type withForce:(int)force withScale:(float)scale {
    _type = type;
    _force = force;
    self.scale = scale;
    self.physicsBody.collisionType = @"powerup";
    self.physicsBody.collisionCategories = @[@"powerup"];
    self.physicsBody.collisionMask = @[@"hero"];
}

- (int)getType {
    return _type;
}

- (int)getForce {
    return _force;
}

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
