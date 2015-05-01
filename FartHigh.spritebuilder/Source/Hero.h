//
//  Hero.h
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy.h"
#import "Powerup.h"
#import "Star.h"

@interface Hero : Enemy
- (void)addBullet:(int)bulletNum;
- (BOOL)hasBullet;
- (int)bullets;
- (void)shoot;
- (void)addShield;
- (BOOL)hasShield;
- (BOOL)hasLives;
- (void)addLives;
- (int)lives;
@end
