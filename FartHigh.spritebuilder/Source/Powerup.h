//
//  Powerup.h
//  FartHigh
//
//  Created by Zuoyou Gu on 4/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#define BULLET_NUM_EVERY_TIME  25
#define POWERUP_TYPES   3

@interface Powerup : CCNode
- (void)withType:(int)type withForce:(int)force withScale:(float)scale;
- (int)getType;
- (int)getForce;

// static variables
+ (float)multipleForce;
+ (void)increaseForce;
+ (void)addTimeBy:(CCTime)delta;
+ (BOOL)timeToLaunch;
+ (void)reset;
@end
