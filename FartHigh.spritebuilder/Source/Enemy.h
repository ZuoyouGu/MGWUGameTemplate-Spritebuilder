//
//  Enemy.h
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#define ENEMY_TYPES     3

@interface Enemy : CCNode
- (BOOL)dead;

- (int)getForce;
- (int)getScore;
- (int)getType;

- (void)minusLive;
- (void)withLives:(int)lives withForce:(int)force withScore:(int)score
         withType:(int)type withScale:(float)scale;
- (void)setLives:(int)lives;
- (void)setForce:(int)force;
- (void)setScore:(int)score;
- (void)setCollisionType;
- (void)setType:(int)type;

// static variables
+ (float)multipleForce;
+ (void)increaseForce;
+ (void)addTimeBy:(CCTime)delta;
+ (BOOL)timeToLaunch;
+ (void)reset;
@end
