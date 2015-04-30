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
}

- (id)initWithLives:(int) lives withForce: (int) force withScore: (int) score {
    _lives = lives;
    _force = force;
    _score = score;
    return self;
}

- (BOOL)dead {
    return _lives == 0;
}

- (void)minusLive {
    
    CCLOG(@"lives: %d", _lives);
    _lives--;
    self.scaleY+=0.1;
    self.scaleX+=0.1;
}

- (int)getForce {
    return _force;
}

- (int)getScore {
    return _score;
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
@end
